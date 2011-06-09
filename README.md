OpenCV for iOS
=======

How to build
=======
opencv_ios_build_script.sh builds binary for armv6/7 and iOS simulator, and integrates them into one static link library file by "lipo" command.

Check out OpenCV-2.2.0 source code into "iOS_OpenCV_build_script" folder.

![](http://sonson.jp/wp/wp-content/uploads/2011/05/opencv_ios01.png)

Next, run "opencv_ios_build_script.sh" to build library file automatically.
OpenCV needs cmake to be built it.
If you have not installed cmake into your Mac, install it.

After building it, following folders are made.

        ./build/lib/
        ./build/include/

Link the files in "./build/lib/" folders, and open Xcode's project property window, and then set "./build/include/" path as header search path.

License
=======
BSD License.

Blog
=======
 * [sonson.jp][]
Sorry, Japanese only....

Dependency
=======
 * [Quartz Help Library][]. Sample  project depends on [Quartz Help Library][], mutually.


[sonson.jp]: http://sonson.jp
[BSD License]: http://www.opensource.org/licenses/bsd-license.php
[Quartz Help Library]: https://github.com/sonsongithub/Quartz-Help-Library
