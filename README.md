# Rutgers Mobile iOS

This is the repository for the Rutgers Mobile iOS client. This is a rewrite as
we're moving off of Appcelerator Titanium.

This app uses CocoaPods for dependency management. To use it, you'll have to
add our specs repository:

  $ pod repo add arutgers git@github.com:rutgersmobile/specs

The 'a' at the beginning is to force it to be used before the regular specs
repo (in case we decide to maintain our own fork of any pods we use in the app.)
Now you can clone the source and type pod in the app directory to get the
deps, then open `Rutgers.xcworkspace` to start deving on the app.

If you'd like to add a new component, however, it should be in its own pod.
See [the wiki for more information](https://github.com/rutgersmobile/ios-client/wiki/Component-Spec).
