#!/bin/bash

zip -r "tuh-mews-source-$(git rev-parse --short HEAD).zip" . \
  -x ".git/*" \
     ".dart_tool/*" \
     "build/*" \
     "android/.gradle/*" \
     "android/app/build/*" \
     "ios/Pods/*" \
     "ios/Runner.xcworkspace/xcuserdata/*" \
     "ios/Runner.xcodeproj/xcuserdata/*" \
     "node_modules/*"