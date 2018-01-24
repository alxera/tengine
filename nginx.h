
/*
 * Copyright (C) Igor Sysoev
 * Copyright (C) Nginx, Inc.
 */


#ifndef _NGINX_H_INCLUDED_
#define _NGINX_H_INCLUDED_


#define nginx_version      1008001
#define NGINX_VERSION      ""
#define NGINX_VER          "Alxera-Server" NGINX_VERSION

#ifdef NGX_BUILD
#define NGINX_VER_BUILD    NGINX_VER " (" NGX_BUILD ")"
#else
#define NGINX_VER_BUILD    NGINX_VER
#endif

#define TENGINE            "Alxera-Server"
#define tengine_version    2002001
#define TENGINE_VERSION    ""
#define TENGINE_VER        TENGINE "" TENGINE_VERSION

#define NGINX_VAR          "Alxera-Server"
#define NGX_OLDPID_EXT     ".oldbin"


#endif /* _NGINX_H_INCLUDED_ */
