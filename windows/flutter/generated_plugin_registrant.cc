//
//  Generated file. Do not edit.
//

#include "generated_plugin_registrant.h"

#include <desktop_window/desktop_window_plugin.h>
#include <flutter_audio_desktop/flutter_audio_desktop_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  DesktopWindowPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DesktopWindowPlugin"));
  FlutterAudioDesktopPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterAudioDesktopPlugin"));
}
