{{flutter_js}}
{{flutter_build_config}}

// Bypass any copy cached before Hosting started revalidating the app shell.
for (const build of _flutter.buildConfig.builds) {
  if (build.mainJsPath) {
    build.mainJsPath += '?formation=single-marker';
  }
}

_flutter.loader.load();
