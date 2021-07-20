// Sparse Voxel Octree and Voxel Cone Tracing
// 
// University of Pennsylvania CIS565 final project
// copyright (c) 2013 Cheng-Tso Lin  

#define GL_GLEXT_PROTOTYPES 1
#define GLM_SWIZZLE 1

#include <GL/glcorearb.h>
#include <GL/glx.h>

#include "../3party/glm/glm/glm.hpp"
#include "../3party/glm.h"

#include <X11/Xlib.h>
#include <X11/Xlib-xcb.h>

#include <iostream>
#include <sstream>
#include <string.h>

#include "glRoutine.h"
#include "objLoader.h"
#include "variables.h"
#include "FreeImage.h"

//Eanble High Performance GPU on Optimus devices
extern "C"
{
    __attribute__((visibility("default"))) DWORD NvOptimusEnablement = 0x00000001;
}

int g_width = 1280;
int g_height = 720;

objLoader g_meshloader;

bool g_quit = false;

xcb_connection_t *xcb_connection;
xcb_window_t xcb_window;
xcb_atom_t xcb_atom_net_wm_name;
xcb_atom_t xcb_atom_utf8_string;
void my_xcb_set_window_title(char const *window_title);

int main(int argc, char *argv[])
{
    //load model
    int numLoadedMesh = 0;
    if( argc ==1 )
     {
        printf("Usage: mesh=[obj file] \n");
        return 0;
    }       
    for( int i = 1; i < argc; ++i )
    {
        string header;
        string data;
        istringstream line(argv[i]);
        getline( line, header, '=' );
        getline( line, data, '=' );
        if( header.compare( "mesh" ) == 0 )
        {
            numLoadedMesh += g_meshloader.load( data );
        }
    }

    if( numLoadedMesh == 0 )
    {
        printf("Usage: mesh=[obj file] \n");
        return 0;
    }

    Display *x11_display = NULL;
    GLXDrawable glx_drawable = -1;
    xcb_atom_t xcb_atom_wm_protocols = -1;
    xcb_atom_t xcb_atom_wm_delete_window = -1;
    {
        // Open Xlib Display
        x11_display = XOpenDisplay(0);
        if (!x11_display)
        {
            printf("Can't open x11_display\n");
            return -1;
        }

        // Get the XCB xcb_connection from the x11_display
        xcb_connection = XGetXCBConnection(x11_display);
        if (!xcb_connection)
        {
            XCloseDisplay(x11_display);
            printf("Can't get xcb xcb_connection from x11_display\n");
            return -1;
        }

        // Acquire event queue ownership
        XSetEventQueueOwner(x11_display, XCBOwnsEventQueue);

        // Find XCB xcb_screen
        int scr = DefaultScreen(x11_display);
        xcb_screen_iterator_t iter = xcb_setup_roots_iterator(xcb_get_setup(xcb_connection));
        for (int i = 0; i < scr; ++i)
        {
            xcb_screen_next(&iter);
        }
        xcb_screen_t *xcb_screen = iter.data;

        // Get a matching FB config
        static int visual_attribs[] =
            {
                GLX_X_RENDERABLE, True,
                GLX_DRAWABLE_TYPE, GLX_WINDOW_BIT,
                GLX_RENDER_TYPE, GLX_RGBA_BIT,
                GLX_X_VISUAL_TYPE, GLX_TRUE_COLOR,
                GLX_RED_SIZE, 8,
                GLX_GREEN_SIZE, 8,
                GLX_BLUE_SIZE, 8,
                GLX_ALPHA_SIZE, 8,
                GLX_DEPTH_SIZE, 24,
                GLX_STENCIL_SIZE, 8,
                GLX_DOUBLEBUFFER, True,
                //GLX_SAMPLE_BUFFERS  , 1,
                //GLX_SAMPLES         , 4,
                None};

        int fbcount;
        GLXFBConfig *fbc = glXChooseFBConfig(x11_display, scr, visual_attribs, &fbcount);
        if (!fbc)
        {
            printf("glXChooseFBConfig failed\n");
            return -1;
        }

        // Select framebuffer config and query visualID
        int best_fbc = 0;
        GLXFBConfig fb_config = fbc[best_fbc];
        XVisualInfo *vi = glXGetVisualFromFBConfig(x11_display, fbc[best_fbc]);
        int visualID = vi->visualid;
        XFree(fbc);

        // NOTE: It is not necessary to create or make current to a glx_context before calling glXGetProcAddressARB
        PFNGLXCREATECONTEXTATTRIBSARBPROC pfn_glXCreateContextAttribsARB = (PFNGLXCREATECONTEXTATTRIBSARBPROC)glXGetProcAddress((GLubyte const *)"glXCreateContextAttribsARB");

        int context_attribs[] = { GLX_CONTEXT_MAJOR_VERSION_ARB,
                                  4,
                                  GLX_CONTEXT_MINOR_VERSION_ARB,
                                  6,
                                  GLX_CONTEXT_PROFILE_MASK_ARB,
                                  GLX_CONTEXT_CORE_PROFILE_BIT_ARB,
#if USE_GL_DEBUG
                                  GLX_CONTEXT_FLAGS_ARB,
                                  GLX_CONTEXT_DEBUG_BIT_ARB,
#endif
                                  None };

        GLXContext glx_context = pfn_glXCreateContextAttribsARB(x11_display, fb_config, 0, True, context_attribs);

        // Sync to ensure any errors generated are processed.
        XSync(x11_display, False);
        if (!glx_context)
        {
            printf("glXCreateContextAttribsARB failed\n");
            return -1;
        }

        // Create XID's for xcb_colormap and xcb_window
        xcb_colormap_t xcb_colormap = xcb_generate_id(xcb_connection);
        xcb_window = xcb_generate_id(xcb_connection);

        // Create xcb_colormap
        xcb_void_cookie_t cookie_create_colormap = xcb_create_colormap(
            xcb_connection,
            XCB_COLORMAP_ALLOC_NONE,
            xcb_colormap,
            xcb_screen->root,
            visualID);

        // Create xcb_window
        uint32_t valuemask = XCB_CW_BACK_PIXEL | XCB_CW_BACKING_STORE | XCB_CW_EVENT_MASK | XCB_CW_COLORMAP;
        uint32_t valuelist[4] = {
            xcb_screen->black_pixel,
            XCB_BACKING_STORE_NOT_USEFUL,
            XCB_EVENT_MASK_BUTTON_PRESS | // Perhaps Bug: XCB_EVENT_MASK_BUTTON_MOTION doesn't work without registering XCB_EVENT_MASK_BUTTON_PRESS
                XCB_EVENT_MASK_POINTER_MOTION |
                XCB_EVENT_MASK_KEY_PRESS |
                XCB_EVENT_MASK_EXPOSURE |
                XCB_EVENT_MASK_STRUCTURE_NOTIFY,
            xcb_colormap};

        xcb_void_cookie_t cookie_create_window = xcb_create_window(
            xcb_connection,
            XCB_COPY_FROM_PARENT,
            xcb_window,
            xcb_screen->root,
            0, 0,
            g_width, g_height,
            0,
            XCB_WINDOW_CLASS_INPUT_OUTPUT,
            visualID,
            valuemask,
            valuelist);

        // Title
        // https://specifications.freedesktop.org/wm-spec/wm-spec-latest.html

        // Delete Window
        // https://www.x.org/releases/current/doc/xorg-docs/icccm/icccm.html

        xcb_intern_atom_cookie_t cookie_net_wm_name = xcb_intern_atom(xcb_connection, 0, 12U, "_NET_WM_NAME");
        xcb_intern_atom_cookie_t cookie_utf8_string = xcb_intern_atom(xcb_connection, 0, 11U, "UTF8_STRING");
        xcb_intern_atom_cookie_t cookie_wm_protocols = xcb_intern_atom(xcb_connection, 0, 12U, "WM_PROTOCOLS");
        xcb_intern_atom_cookie_t cookie_wm_delete_window = xcb_intern_atom(xcb_connection, 0, 16U, "WM_DELETE_WINDOW");

        // implicit xcb_flush
        xcb_generic_error_t *error_generic = xcb_request_check(xcb_connection, cookie_create_colormap);
        assert(error_generic == NULL);

        error_generic = xcb_request_check(xcb_connection, cookie_create_window);
        assert(error_generic == NULL);

        xcb_intern_atom_reply_t *reply_net_wm_name = xcb_intern_atom_reply(xcb_connection, cookie_net_wm_name, &error_generic);
        assert(error_generic == NULL);
        xcb_atom_net_wm_name = reply_net_wm_name->atom;
        free(reply_net_wm_name);

        xcb_intern_atom_reply_t *reply_utf8_string = xcb_intern_atom_reply(xcb_connection, cookie_utf8_string, &error_generic);
        assert(error_generic == NULL);
        xcb_atom_utf8_string = reply_utf8_string->atom;
        free(reply_utf8_string);

        xcb_intern_atom_reply_t *reply_wm_protocols = xcb_intern_atom_reply(xcb_connection, cookie_wm_protocols, &error_generic);
        assert(error_generic == NULL);
        xcb_atom_wm_protocols = reply_wm_protocols->atom;
        free(reply_wm_protocols);

        xcb_intern_atom_reply_t *reply_wm_delete_window = xcb_intern_atom_reply(xcb_connection, cookie_wm_delete_window, &error_generic);
        assert(error_generic == NULL);
        xcb_atom_wm_delete_window = reply_wm_delete_window->atom;
        free(reply_wm_delete_window);

        //
        xcb_void_cookie_t cookie_change_property_net_wm_name = xcb_change_property_checked(xcb_connection, XCB_PROP_MODE_REPLACE, xcb_window, xcb_atom_net_wm_name, xcb_atom_utf8_string, 8U, 19U, "Sparse Voxel Octree");

        xcb_void_cookie_t cookie_change_property_wm_protocols = xcb_change_property_checked(xcb_connection, XCB_PROP_MODE_REPLACE, xcb_window, xcb_atom_wm_protocols, XCB_ATOM_ATOM, 32U, 1U, &xcb_atom_wm_delete_window);

        xcb_void_cookie_t cookie_map_window = xcb_map_window_checked(xcb_connection, xcb_window);

        error_generic = xcb_request_check(xcb_connection, cookie_change_property_net_wm_name);
        assert(error_generic == NULL);

        error_generic = xcb_request_check(xcb_connection, cookie_change_property_wm_protocols);
        assert(error_generic == NULL);

        error_generic = xcb_request_check(xcb_connection, cookie_map_window);
        assert(error_generic == NULL);

        // NOTE: xcb_window must be mapped before glXMakeContextCurrent
        // Create GLX Window
        GLXWindow glx_window = glXCreateWindow(x11_display, fb_config, xcb_window, NULL);
        if (!glx_window)
        {
            printf("glXCreateWindow failed\n");
            return -1;
        }

        glx_drawable = glx_window;

        // Make OpenGL context current
        if (!glXMakeContextCurrent(x11_display, glx_drawable, glx_drawable, glx_context))
        {
            printf("glXMakeContextCurrent failed\n");
            return -1;
        }
    }

#if USE_GL_DEBUG
    glDebugMessageCallback(my_gl_debug_message, NULL);
	glDebugMessageControl(GL_DONT_CARE, GL_DONT_CARE, GL_DONT_CARE, 0U, NULL, GL_TRUE);
	glDebugMessageControl(GL_DONT_CARE, GL_DEBUG_TYPE_OTHER, GL_DONT_CARE, 0U, NULL, GL_FALSE);

    glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS);
#endif

    // Initialize
    printf("%s %s %s \n", "OpenGL version ", glGetString(GL_VERSION), "supported");

    FreeImage_Initialise();

    initShader();
    initFBO(g_width, g_height);
    initVertexData(); 
    buildVoxelList(); //build a voxel fragment list
#if USE_SPARSE_OCTREE == 1
    buildSVO();       //build a sparse voxel octree
    deleteVoxelList();
    //octreeTo3Dtex();  //for visualization purpose
#else
      
    octreeTo3Dtex();  //for visualization purpose
    deleteVoxelList();
#endif

    initLight();

    //Main Loop
    {
        while (!g_quit)
        {
            xcb_generic_event_t *event;
            while (NULL != (event = xcb_poll_for_event(xcb_connection)))
            {
                // The most significant bit(uint8_t(0X80)) in this code is set if the event was generated from a SendEvent request.
                // https://www.x.org/releases/current/doc/xproto/x11protocol.html#event_format
                switch (event->response_type & (~uint8_t(0X80)))
                {
                case XCB_MOTION_NOTIFY:
                {
                    assert(XCB_MOTION_NOTIFY == (event->response_type & (~uint8_t(0X80))));
                    xcb_motion_notify_event_t *motion_notify = (xcb_motion_notify_event_t *)event;

                    if (motion_notify->event == xcb_window)
                    {
                        // XCB_BUTTON_MASK_1 WM_LBUTTONDOWN
                        // XCB_BUTTON_MASK_2 WM_MBUTTONDOWN
                        // XCB_BUTTON_MASK_3 WM_RBUTTONDOWN
                        int button = 0;
                        if (0 != (motion_notify->state & XCB_BUTTON_MASK_3))
                        {
                            button |= (1 << 3);
                        }
                        else if (0 != (motion_notify->state & XCB_BUTTON_MASK_1))
                        {
                            button |= (1 << 1);
                        }
                        my_x11_motion(button, motion_notify->event_x, motion_notify->event_y);
                    }
                }
                break;
                case XCB_KEY_PRESS:
                {
                    assert(XCB_KEY_PRESS == (event->response_type & (~uint8_t(0X80))));
                    xcb_key_press_event_t *key_press = (xcb_key_press_event_t *)event;

                    if (key_press->event == xcb_window)
                    {
                        my_x11_keyboard(key_press->detail);
                    }
                }
                break;
                case XCB_EXPOSE:
                {
                    assert(XCB_EXPOSE == (event->response_type & (~uint8_t(0X80))));
                    xcb_expose_event_t *expose = (xcb_expose_event_t *)event;

                    if (expose->window == xcb_window)
                    {
                        my_gl_reshape(expose->width, expose->height);
                    }
                }
                break;
                case XCB_CONFIGURE_NOTIFY:
                {
                    assert(XCB_CONFIGURE_NOTIFY == (event->response_type & (~uint8_t(0X80))));
                    xcb_configure_notify_event_t *configure_notify = (xcb_configure_notify_event_t *)event;

                    if (configure_notify->window == xcb_window)
                    {
                        my_gl_reshape(configure_notify->width, configure_notify->height);
                    }
                }
                break;
                case XCB_CLIENT_MESSAGE:
                {
                    assert(XCB_CLIENT_MESSAGE == (event->response_type & (~uint8_t(0X80))));
                    xcb_client_message_event_t *client_message = reinterpret_cast<xcb_client_message_event_t *>(event);

                    // WM_DESTROY
                    if (client_message->window == xcb_window && client_message->type == xcb_atom_wm_protocols && client_message->format == 32U && client_message->data.data32[0] == xcb_atom_wm_delete_window)
                    {
                        g_quit = true;
                    }
                }
                break;
                default:
                    break;
                }
                free(event);
            }
            my_gl_display();
            glXSwapBuffers(x11_display, glx_drawable);
        }
    }

    // Cleanup
    XCloseDisplay(x11_display);

    FreeImage_DeInitialise();

    return 0;
}

void my_xcb_set_window_title(char const *window_title)
{
    xcb_void_cookie_t cookie_change_property_net_wm_name = xcb_change_property_checked(xcb_connection, XCB_PROP_MODE_REPLACE, xcb_window, xcb_atom_net_wm_name, xcb_atom_utf8_string, 8U, strlen(window_title), window_title);

    xcb_generic_error_t *error_generic = xcb_request_check(xcb_connection, cookie_change_property_net_wm_name);
    assert(error_generic == NULL);
}