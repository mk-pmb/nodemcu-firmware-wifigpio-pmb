#ifndef __USER_CONFIG_H__
#define __USER_CONFIG_H__

#define FLASH_4M
#define BIT_RATE_DEFAULT BIT_RATE_115200
// ^-- A safe default. You can still re-configure it in init.lua.
//     (My dev board seems to support 1'152'000 as well, i.e. 10x.)

//                            .---- ×  1 MiB
//                            |.--- × 64 KiB
//                            ||.-- ×  4 KiB
//                        0x |||  .-- bytes
#define LUA_FLASH_STORE   0x00030000
// #define SPIFFS_MAX_FILESYSTEM_SIZE 0x40000

//                                  .---- ×  1 MiB
//                                  |.--- × 64 KiB
//                                  ||.-- ×  4 KiB
//                              0x  |||  .-- bytes
#define SPIFFS_FIXED_LOCATION   0x00100000










#define BUILD_SPIFFS
#define SPIFFS_CACHE 1
#define SPIFFS_MAX_OPEN_FILES 32
#define FS_OBJ_NAME_LEN 63


#define SHA2_ENABLE
#define SSL_BUFFER_SIZE 4096
#define SSL_MAX_FRAGMENT_LENGTH_CODE  MBEDTLS_SSL_MAX_FRAG_LEN_4096



#define GPIO_INTERRUPT_ENABLE
#define GPIO_INTERRUPT_HOOK_ENABLE

#define TIMER_SUSPEND_ENABLE
#define PMSLEEP_ENABLE


#define NET_PING_ENABLE

//#define WIFI_SMART_ENABLE
#define WIFI_SDK_EVENT_MONITOR_ENABLE
#define WIFI_EVENT_MONITOR_DISCONNECT_REASON_LIST_ENABLE

#define WIFI_STA_HOSTNAME "NodeMCU"
#define WIFI_STA_HOSTNAME_APPEND_MAC
#define ENDUSER_SETUP_AP_SSID "SetupNodeMCU"

//#define I2C_MASTER_GPIO16_ENABLE
//#define I2C_MASTER_OLD_VERSION

// *** Heareafter, there be demons ***

// The remaining options are advanced configuration options and you should only
// change this if you have tracked the implications through the Firmware sources
// and understand the these.

#define NODEMCU_EAGLEROM_PARTITION        1
#define NODEMCU_IROM0TEXT_PARTITION       2
#define NODEMCU_LFS0_PARTITION            3
#define NODEMCU_LFS1_PARTITION            4
#define NODEMCU_TLSCERT_PARTITION         5
#define NODEMCU_SPIFFS0_PARTITION         6
#define NODEMCU_SPIFFS1_PARTITION         7

#ifndef LUA_FLASH_STORE
#  define LUA_FLASH_STORE                 0x0
#endif

#ifndef SPIFFS_FIXED_LOCATION
  #define SPIFFS_FIXED_LOCATION           0x0
  // You'll rarely need to customize this, because nowadays
  // it's usually overruled by the partition table anyway.
#endif
#ifndef SPIFFS_MAX_FILESYSTEM_SIZE
#  define SPIFFS_MAX_FILESYSTEM_SIZE      0xFFFFFFFF
#endif
//#define SPIFFS_SIZE_1M_BOUNDARY

#define LUA_TASK_PRIO             USER_TASK_PRIO_0
#define LUA_PROCESS_LINE_SIG      2
// LUAI_OPTIMIZE_DEBUG 0 = Keep all debug; 1 = keep line number info; 2 = remove all debug
#define LUAI_OPTIMIZE_DEBUG       1
#define READLINE_INTERVAL        80
#define STRBUF_DEFAULT_INCREMENT  3
#define LUA_USE_BUILTIN_DEBUG_MINIMAL // for debug.getregistry() and debug.traceback()

#if defined(DEVELOPMENT_TOOLS) && defined(DEVELOPMENT_USE_GDB)
extern void LUA_DEBUG_HOOK (void);
#define lua_assert(x)    ((x) ? (void) 0 : LUA_DEBUG_HOOK ())
#elif defined(DEVELOPMENT_TOOLS) && defined(LUA_CROSS_COMPILER)
extern void luaL_assertfail(const char *file, int line, const char *message);
#define lua_assert(x)    ((x) ? (void) 0 : luaL_assertfail(__FILE__, __LINE__, #x))
#else
#define lua_assert(x)    ((void) (x))
#endif

#if !defined(LUA_NUMBER_INTEGRAL) && !defined (LUA_DWORD_ALIGNED_TVALUES)
  #define LUA_PACK_TVALUES
#else
  #undef LUA_PACK_TVALUES
#endif

#ifdef DEVELOP_VERSION
#define NODE_DEBUG
#define COAP_DEBUG
#endif /* DEVELOP_VERSION */


#if !defined(LUA_CROSS_COMPILER) && !defined(dbg_printf)
extern void dbg_printf(const char *fmt, ...);
#endif

#ifdef NODE_DEBUG
#define NODE_DBG dbg_printf
#else
#define NODE_DBG( ... )
#endif  /* NODE_DEBUG */

#define NODE_ERROR
#ifdef NODE_ERROR
#define NODE_ERR dbg_printf
#else
#define NODE_ERR( ... )
#endif  /* NODE_ERROR */

// #define GPIO_SAFE_NO_INTR_ENABLE
#define ICACHE_STORE_TYPEDEF_ATTR __attribute__((aligned(4),packed))
#define ICACHE_STORE_ATTR __attribute__((aligned(4)))
#define ICACHE_STRING(x) ICACHE_STRING2(x)
#define ICACHE_STRING2(x) #x
#define ICACHE_RAM_ATTR __attribute__((section(".iram0.text." __FILE__ "." ICACHE_STRING(__LINE__))))
#ifdef  GPIO_SAFE_NO_INTR_ENABLE
#define NO_INTR_CODE ICACHE_RAM_ATTR __attribute__ ((noinline))
#else
#define NO_INTR_CODE inline
#endif

#endif  /* __USER_CONFIG_H__ */
