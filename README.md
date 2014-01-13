# Rutgers Mobile iOS

This is the repository for the Rutgers Mobile iOS client. This is a rewrite as
we're moving off of Appcelerator Titanium.

This app uses CocoaPods for dependency management. To use it, you'll have to
add our specs repository:

    $ pod repo add rutgers git@github.com:rutgersmobile/specs

Now you can clone the source and type pod in the app directory to get the
deps, then open `Rutgers.xcworkspace` to start deving on the app.

If you'd like to add a new component, however, it should be in its own pod.
See [the wiki for more information](https://github.com/rutgersmobile/ios-client/wiki/Component-Spec).
