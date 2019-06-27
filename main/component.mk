#
# "main" pseudo-component makefile.
#
# (Uses default behaviour of compiling all source files in directory, adding 'include' to include path.)
CFLAGS += -O3 -DPOSIX -DLINKALL -DLOOPBACK -DNO_FAAD -DRESAMPLE16 -DEMBEDDED -DTREMOR_ONLY -DBYTES_PER_FRAME=4 	\
	-I$(COMPONENT_PATH)/../components/codecs/inc			\
	-I$(COMPONENT_PATH)/../components/codecs/inc/mad 		\
	-I$(COMPONENT_PATH)/../components/codecs/inc/alac		\
	-I$(COMPONENT_PATH)/../components/codecs/inc/helix-aac	\
	-I$(COMPONENT_PATH)/../components/codecs/inc/vorbis 	\
	-I$(COMPONENT_PATH)/../components/codecs/inc/soxr 		\
	-I$(COMPONENT_PATH)/../components/codecs/inc/resample16	\
	-I$(COMPONENT_PATH)/../components/platform_esp32 
	
LDFLAGS += -s

#	-I$(COMPONENT_PATH)/../components/codecs/inc/faad2



