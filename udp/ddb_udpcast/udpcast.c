/*
    UDP Unicast DSP plugin for DeaDBeeF Player
	Copyright (C) 2017 ed <irc.rizon.net> <spam@ocv.me>

	Based on:
      Mono to stereo converter DSP plugin for DeaDBeeF Player
      Copyright (C) 2009-2014 Alexey Yakovenko

    This software is provided 'as-is', without any express or implied
    warranty.  In no event will the authors be held liable for any damages
    arising from the use of this software.

    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:

    1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.

    2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.

    3. This notice may not be removed or altered from any source distribution.
*/

#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <deadbeef/deadbeef.h>

#include <netinet/in.h>  // sockaddr_in
#include <arpa/inet.h>   // inet_aton
#include <unistd.h>      // close

enum {
    UDPCAST_PARAM_HOST,
    UDPCAST_PARAM_PORT,
    UDPCAST_PARAM_COUNT
};

static DB_functions_t* deadbeef;
static DB_dsp_t plugin;

typedef struct {
    ddb_dsp_context_t ctx;
    char* host;
    int port;
    int need_init;
    int need_config;
    struct sockaddr_in s_addr;
    int sockfd;
} ddb_udpcast_t;

ddb_dsp_context_t* udpcast_open(void)
{
	fprintf(stderr, "\033[1;33m>>> udpcast_open\033[0m\n");

    ddb_udpcast_t* udpcast = malloc(sizeof(ddb_udpcast_t));
    DDB_INIT_DSP_CONTEXT(udpcast,ddb_udpcast_t,&plugin);

    // initialize
    udpcast->host = "127.0.0.1";
    udpcast->port = 1479;
    udpcast->need_init = 1;
    udpcast->need_config = 1;
    
    return (ddb_dsp_context_t*)udpcast;
}

void udpcast_close(ddb_dsp_context_t* ctx)
{
	fprintf(stderr, "\033[1;33m>>> udpcast_close\033[0m\n");

    ddb_udpcast_t* udpcast = (ddb_udpcast_t*)ctx;

    // free instance-specific allocations
    if (udpcast->need_init == 1)
		close(udpcast->sockfd);
	udpcast->need_init = 1;

    free(udpcast);
}

void udpcast_reset(ddb_dsp_context_t* ctx)
{
	fprintf(stderr, "\033[1;33m>>> udpcast_reset\033[0m\n");
    // use this method to flush dsp buffers, reset filters, etc
}

int udpcast_process(ddb_dsp_context_t* ctx, float* samples, int nframes, int maxframes, ddb_waveformat_t* fmt, float* r)
{
	ddb_udpcast_t* udpcast = (ddb_udpcast_t*)ctx;
	
    if (udpcast->need_init == 1)
    {
		fprintf(stderr, "\033[36m[udpcast] \033[32m*** initializing ***\033[0m\n");
		
		udpcast->sockfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
		if (udpcast->sockfd < 0)
		{
			fprintf(stderr, "\033[36m[udpcast] \033[31mERROR opening socket\033[0m\n");
			return nframes;
		}
		
		memset((char*)&udpcast->s_addr, 0, sizeof(udpcast->s_addr));
		udpcast->s_addr.sin_family = AF_INET;
		
		udpcast->need_init = 0;
	}
	
	if (udpcast->need_config == 1)
	{
		fprintf(stderr, "\033[36m[udpcast] \033[32m*** configuring ***\033[0m\n");
		
		udpcast->s_addr.sin_port = htons(udpcast->port);
		if (inet_aton(udpcast->host, &udpcast->s_addr.sin_addr) == 0)
		{
			fprintf(stderr, "\033[36m[udpcast] \033[31mERROR converting host ip\033[0m\n");
			return nframes;
		}
		udpcast->need_config = 0;
	}
	
	// 16bit 2ch = 4 byte per sample, up to 127 samples per packet
	const int max_sz = 508;
	char buf[max_sz];
	
	// audio data is channels interleaved per sample,
	// nframes is number of samples per channel,
	// total number of samples is:
	const int nsamples = nframes * fmt->channels;
	
	for (int offset = 0; offset < nsamples; )
	{
		int sz = nsamples - offset;
		if (sz > max_sz / 2)
			sz = max_sz / 2;
		
		int bpos;
		for (bpos = 0, sz += offset; offset < sz; offset++, bpos += 2)
		{
			//fprintf(stdout, "-!- %d / %d -- %f  =  %d\n",
			//	offset, sz, samples[offset], (int16_t)(samples[offset] * 0xffff));

			*((int16_t*)(&buf[bpos])) = (int16_t)(samples[offset] * 0x7fff);
			//int16_t v = (int16_t)(samples[offset] * 0xffff);
			//memcpy(&buf[bpos], &v, sizeof(int16_t));
		}
		
		if (sendto(udpcast->sockfd, buf, bpos, 0,
			(struct sockaddr*)&udpcast->s_addr, sizeof(udpcast->s_addr)) < 0)
		{
			fprintf(stderr, "\033[36m[udpcast] \033[31mERROR sending udp packet\033[0m\n");
		}
		//fprintf(stdout, "sent %d bytes, %d / %d samples\n", bpos, offset, nsamples);
	}
	
    return nframes;
}

const char* udpcast_get_param_name(int p)
{
	//fprintf(stderr, "\033[36m[udpcast] get_param_name(%d)\033[0m\n", p);
    switch(p)
    {
		case UDPCAST_PARAM_HOST:
			return "127.0.0.1";
		case UDPCAST_PARAM_PORT:
			return "1479";
		default:
			fprintf(stderr, "\033[36m[udpcast_get_param_name] \033[33mWARNING: invalid param index (%d)\033[0m\n", p);
    }
    return NULL;
}

int udpcast_num_params(void)
{
	//fprintf(stderr, "\033[36m[udpcast] udpcast_num_params\033[0m\n");
    return UDPCAST_PARAM_COUNT;
}

void udpcast_set_param(ddb_dsp_context_t* ctx, int p, const char* val)
{
	//fprintf(stderr, "\033[36m[udpcast] set_param(%d) => %s\033[0m\n", p, val);
    ddb_udpcast_t* udpcast = (ddb_udpcast_t*)ctx;
    switch(p)
    {
		case UDPCAST_PARAM_HOST:
			fprintf(stderr, "\033[36m[udpcast] storing host [%s]\033[0m\n", val);
			//udpcast->host = strdup(val);
			size_t len = 1 + strlen(val);
			char *nca = malloc(len);
			if (nca && memcpy(nca, val, len))
				udpcast->host = nca;
			//fprintf(stderr, "\033[36m[udpcast] ok\033[0m\n");
			break;
		case UDPCAST_PARAM_PORT:
			fprintf(stderr, "\033[36m[udpcast] storing port [%s]\033[0m\n", val);
			udpcast->port = atoi(val);
			//fprintf(stderr, "\033[36m[udpcast] ok\033[0m\n");
			break;
		default:
			fprintf(stderr, "\033[36m[udpcast_set_param] \033[33mWARNING: invalid param index (%d)\033[0m\n", p);
    }
    udpcast->need_config = 1;
}

void udpcast_get_param(ddb_dsp_context_t* ctx, int p, char* val, int sz)
{
	//fprintf(stderr, "\033[36m[udpcast] get_param(%d)\033[0m\n", p);
    ddb_udpcast_t* udpcast = (ddb_udpcast_t*)ctx;
    switch(p)
    {
		case UDPCAST_PARAM_HOST:
			snprintf(val, sz, "%s", udpcast->host);
			break;
		case UDPCAST_PARAM_PORT:
			snprintf(val, sz, "%d", udpcast->port);
			break;
		default:
			fprintf(stderr, "\033[36m[udpcast_get_param] \033[33mWARNING: invalid param index (%d)\033[0m\n", p);
    }
}

static const char settings_dlg[] =
    "property \"Host:\" entry 0 127.0.0.1;\n"
    "property \"Port:\" entry 1 1479;\n"
;

static DB_dsp_t plugin = {
    .plugin.api_vmajor = 1,
    .plugin.api_vminor = 0,
    .open = udpcast_open,
    .close = udpcast_close,
    .process = udpcast_process,
    .plugin.version_major = 1,
    .plugin.version_minor = 0,
    .plugin.type = DB_PLUGIN_DSP,
    .plugin.id = "udpcast",
    .plugin.name = "UDP Unicast",
    .plugin.descr = "Transmit audio data over UDP",
    .plugin.copyright = 
        "UDP Unicast DSP plugin for DeaDBeeF Player\n"
        "Copyright (C) 2017 ed <irc.rizon.net>\n"
        "\n"
        "This software is provided 'as-is', without any express or implied\n"
        "warranty.  In no event will the authors be held liable for any damages\n"
        "arising from the use of this software.\n"
        "\n"
        "Permission is granted to anyone to use this software for any purpose,\n"
        "including commercial applications, and to alter it and redistribute it\n"
        "freely, subject to the following restrictions:\n"
        "\n"
        "1. The origin of this software must not be misrepresented; you must not\n"
        " claim that you wrote the original software. If you use this software\n"
        " in a product, an acknowledgment in the product documentation would be\n"
        " appreciated but is not required.\n"
        "\n"
        "2. Altered source versions must be plainly marked as such, and must not be\n"
        " misrepresented as being the original software.\n"
        "\n"
        "3. This notice may not be removed or altered from any source distribution.\n"
    ,
    .plugin.website = "https://ocv.me/dev",
    .num_params = udpcast_num_params,
    .get_param_name = udpcast_get_param_name,
    .set_param = udpcast_set_param,
    .get_param = udpcast_get_param,
    .reset = udpcast_reset,
    .configdialog = settings_dlg,
};

DB_plugin_t* ddb_udpcast_load(DB_functions_t* f)
{
    deadbeef = f;
    return &plugin.plugin;
}

