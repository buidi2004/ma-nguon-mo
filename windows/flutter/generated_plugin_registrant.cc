//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <file_selector_windows/file_selector_windows.h>
#include <smart_splash_kit/smart_splash_kit_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FileSelectorWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FileSelectorWindows"));
  SmartSplashKitPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("SmartSplashKitPlugin"));
}
