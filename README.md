# cl-kytea
Common Lisp interface to KyTea

## How to Install


Install KyTea.


Build `libkytea_wrap.so`.

```
$ cd <path/to/cl-kytea>/kytea_wrap/
$ g++ -I<path/to/kytea/include/> -shared -fPIC -o libkytea_wrap.so kytea_wrap.cpp
```

Add paths to `LD_LIBRARY_PATH`.

```
export LD_LIBRARY_PATH="<path/to/kytea/lib":$LD_LIBRARY_PATH
export LD_LIBRARY_PATH="<path/to/cl-kytea>/kytea-wrap":$LD_LIBRARY_PATH
```

Then, you can load `cl-kytea`.

```
CL-USER> (ql:quickload :cl-kytea)
To load "cl-kytea":
  Load 1 ASDF system:
    cl-kytea
; Loading "cl-kytea"
.
(:CL-KYTEA)
```

## How to Use

```
CL-USER> (defvar *k* (cl-kytea:load-kytea))
*K*
CL-USER> (cl-kytea:calculate-ws *k* "東京に行きました")
("東京" "に" "行" "き" "ま" "し" "た")
```
