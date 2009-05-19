{include resources/header.md}

# ASDF Manual

## Table of Contents

  * [asdf: another system definition facility][1]
  * [1 Using asdf to load systems][2]

    * [1.1 Downloading asdf][2]
    * [1.2 Setting up asdf][2]
    * [1.3 Setting up a system to be loaded][2]
    * [1.4 Loading a system][2]

  * [2 Defining systems with defsystem][3]

    * [2.1 The defsystem form][4]
    * [2.2 A more involved example][5]
    * [2.3 The defsystem grammar][6]

      * [2.3.1 Serial dependencies][6]
      * [2.3.2 Source location][6]

    * [2.4 Other code in .asd files][7]

  * [3 The object model of asdf][8]

    * [3.1 Operations][9]

      * [3.1.1 Predefined operations of asdf][10]
      * [3.1.2 Creating new operations][11]

    * [3.2 Components][12]

      * [3.2.1 Common attributes of components][13]

        * [3.2.1.1 Name][13]
        * [3.2.1.2 Version identifier][13]
        * [3.2.1.3 Required features][13]
        * [3.2.1.4 Dependencies][13]
        * [3.2.1.5 pathname][13]
        * [3.2.1.6 properties][13]

      * [3.2.2 Pre-defined subclasses of component][14]
      * [3.2.3 Creating new component types][15]

  * [4 Error handling][16]
  * [5 Compilation error and warning handling][17]
  * [6 Additional Functionality][18]
  * [7 Getting the latest version][19]
  * [8 TODO list][20]
  * [9 missing bits in implementation][21]
  * [10 Inspiration][22]

    * [10.1 mk-defsystem (defsystem-3.x)][22]
    * [10.2 defsystem-4 proposal][22]
    * [10.3 kmp's "The Description of Large Systems", MIT AI Memu 801][22]

  * [Concept Index][23]
  * [Function and Class Index][24]
  * [Variable Index][25]

* * *

Next: [Using asdf to load systems][2], Previous: [(dir)][26], Up: [(dir)][26]

## asdf: another system definition facility

This manual describes asdf, a system definition facility for Common Lisp programs and libraries. 

asdf Copyright (C) 2001-2007 Daniel Barlow and contributors 

This manual Copyright (C) 2001-2007 Daniel Barlow and contributors 

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: 

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. 

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 

  * [Using asdf to load systems][2]
  * [Defining systems with defsystem][3]
  * [The object model of asdf][8]
  * [Error handling][16]
  * [Compilation error and warning handling][17]
  * [Miscellaneous additional functionality][18]
  * [Getting the latest version][19]
  * [TODO list][20]
  * [missing bits in implementation][21]
  * [Inspiration][22]
  * [Concept Index][23]
  * [Function and Class Index][24]
  * [Variable Index][25]

--- The Detailed Node Listing --- 

Defining systems with defsystem 

  * [The defsystem form][4]
  * [A more involved example][5]
  * [The defsystem grammar][6]

The object model of asdf 

  * [Operations][9]
  * [Components][12]

Operations 

  * [Predefined operations of asdf][10]
  * [Creating new operations][11]

Components 

  * [Common attributes of components][13]
  * [Pre-defined subclasses of component][14]
  * [Creating new component types][15]

properties 

  * [Pre-defined subclasses of component][14]
  * [Creating new component types][15]

* * *

Next: [Defining systems with defsystem][3], Previous: [Top][1], Up: [Top][1]

## 1 Using asdf to load systems

This chapter describes how to use asdf to compile and load ready-made Lisp programs and libraries. 

### 1.1 Downloading asdf

Some Lisp implementations (such as SBCL and OpenMCL) come with asdf included already, so you don't need to download it separately. Consult your Lisp system's documentation. If you need to download asdf and install it by hand, the canonical source is the cCLan CVS repository at [http://cvs.sourceforge.net/cgi-bin/viewcvs.cgi/cclan/asdf/][27]. 

### 1.2 Setting up asdf

The single file asdf.lisp is all you need to use asdf normally. Once you load it in a running Lisp, you're ready to use asdf. For maximum convenience you might want to have asdf loaded whenever you start your Lisp implementation, for example by loading it from the startup script or dumping a custom core - check your Lisp implementation's manual for details. 

The variable `asdf:*central-registry*` is a list of "system
directory designators"{footnote "When we say 'directory'
here, we mean 'designator for a pathname with a supplied
DIRECTORY component'."}. A system directory designator is a
form which will be evaluated whenever a system is to be
found, and must evaluate to a directory to look in. You might
want to set or augment `*central-registry*` in your Lisp init
file, for example:

         (setf asdf:*central-registry*
           (list* '*default-pathname-defaults*
                  #p"/home/me/cl/systems/"
                  #p"/usr/share/common-lisp/systems/"
                  asdf:*central-registry*))


### 1.3 Setting up a system to be loaded

To compile and load a system, you need to ensure that a
symbolic link to its system definition is in one of the
directories in `*central-registry*`{footnote "It is possible
to customize the system definition file search. That's
considered advanced use, and covered later: search forward
for `*system-definition-search-functions*`. See [Defining
systems with defsystem][3]."}.

For example, if `#p"/home/me/cl/systems/"` (note the trailing slash) is a member of `*central-registry*`, you would set up a system foo that is stored in a directory /home/me/src/foo/ for loading with asdf with the following commands at the shell (this has to be done only once): 
    
         $ cd /home/me/cl/systems/
         $ ln -s ~/src/foo/foo.asd .
    

### 1.4 Loading a system

The system foo is loaded (and compiled, if necessary) by evaluating the following form in your Lisp implementation: 
    
         (asdf:operate 'asdf:load-op 'foo)
    

Output from asdf and asdf extensions are supposed to be sent to the CL stream `*standard-output*`, and so rebinding that stream around calls to `asdf:operate` should redirect all output from asdf operations. 

That's all you need to know to use asdf to load systems written by others. The rest of this manual deals with writing system definitions for Lisp software you write yourself. 

* * *

Next: [The object model of asdf][8], Previous: [Using asdf to load systems][2], Up: [Top][1]

## 2 Defining systems with defsystem

This chapter describes how to use asdf to define systems and develop software. 

  * [The defsystem form][4]
  * [A more involved example][5]
  * [The defsystem grammar][6]
  * [Other code in .asd files][7]

* * *

Next: [A more involved example][5], Previous: [Defining systems with defsystem][3], Up: [Defining systems with defsystem][3]

### 2.1 The defsystem form

Systems can be constructed programmatically by instantiating components using make-instance. Most of the time, however, it is much more practical to use a static `defsystem` form. This section begins with an example of a system definition, then gives the full grammar of `defsystem`. 

Let's look at a simple system. This is a complete file that would usually be saved as hello-lisp.asd: 
    
         (defpackage hello-lisp-system
           (:use :common-lisp :asdf))
         
         (in-package :hello-lisp-system)
         
         (defsystem "hello-lisp"
             :description "hello-lisp: a sample Lisp system."
             :version "0.2"
             :author "Joe User <joe@example.com>"
             :licence "Public Domain"
             :components ((:file "packages")
                          (:file "macros" :depends-on ("packages"))
                          (:file "hello" :depends-on ("macros"))))
    

Some notes about this example: 

  * The file starts with `defpackage` and `in-package` forms to make and use a package expressly for defining this system in. This package is named by taking the system name and suffixing `-system` - note that it is _not_ the same package as you will use for the application code. 

This is not absolutely required by asdf, but helps avoid namespace pollution and so is considered good form. 

  * The defsystem form defines a system named "hello-lisp"
    that contains three source files: packages, macros and
    hello.

  * The file macros depends on packages (presumably because
    the package it's in is defined in packages), and the file
    hello depends on macros (and hence, transitively on
    packages). This means that asdf will compile and load
    packages and macros before starting the compilation of
    file hello.

  * The files are located in the same directory as the file
    with the system definition. asdf resolves symbolic links
    before loading the system definition file and stores its
    location in the resulting system{footnote "It is
    possible, though almost never necessary, to override this
    behaviour."}. This is a good thing because the user can
    move the system sources without having to edit the system
    definition.

* * *

Next: [The defsystem grammar][6], Previous: [The defsystem form][4], Up: [Defining systems with defsystem][3]

### 2.2 A more involved example

Let's illustrate some more involved uses of `defsystem` via a slightly convoluted example: 
    
         (defsystem "foo"
           :version "1.0"
           :components ((:module "foo" :components ((:file "bar") (:file"baz")
                                                    (:file "quux"))
         	        :perform (compile-op :after (op c)
         			  (do-something c))
         		:explain (compile-op :after (op c)
         			  (explain-something c)))
                        (:file "blah")))
    

The method-form tokens need explaining: essentially, this part: 
    
         	        :perform (compile-op :after (op c)
         			  (do-something c))
         		:explain (compile-op :after (op c)
         			  (explain-something c))
    

has the effect of 
    
         (defmethod perform :after ((op compile-op) (c (eql ...)))
         	   (do-something c))
         (defmethod explain :after ((op compile-op) (c (eql ...)))
         	   (explain-something c))
    

where `...` is the component in question; note that although this also supports `:before` methods, they may not do what you want them to - a `:before` method on perform `((op compile-op) (c (eql ...)))` will run after all the dependencies and sub-components have been processed, but before the component in question has been compiled. 

* * *

Next: [Other code in .asd files][7], Previous: [A more involved example][5], Up: [Defining systems with defsystem][3]

### 2.3 The defsystem grammar
    
    system-definition := ( defsystem system-designator {option}* )
    
    option := :components component-list
            | :pathname pathname
            | :default-component-class
            | :perform method-form 
            | :explain method-form
    	| :output-files  method-form
            | :operation-done-p method-form
            | :depends-on ( {dependency-def}* ) 
    	| :serial [ t | nil ]
            | :in-order-to ( {dependency}+ )
    
    component-list := ( {component-def}* )
                    
    component-def  := simple-component-name
                    | ( component-type name {option}* )
    
    component-type := :module | :file | :system | other-component-type
    
    dependency-def := simple-component-name
                   | ( :feature name )
                   | ( :version simple-component-name version-specifier)
    
    dependency := (dependent-op {requirement}+)
    requirement := (required-op {required-component}+)
                 | (feature feature-name)
    dependent-op := operation-name
    required-op := operation-name | feature
    
    simple-component-name := string
                          |  symbol
    

#### 2.3.1 Serial dependencies

If the `:serial t` option is specified for a module, asdf will add dependencies for each each child component, on all the children textually preceding it. This is done as if by `:depends-on`. 
    
         :components ((:file "a") (:file "b") (:file "c"))
         :serial t
    

is equivalent to 
    
         :components ((:file "a")
         	     (:file "b" :depends-on ("a"))
         	     (:file "c" :depends-on ("a" "b")))
    

#### 2.3.2 Source location

The `:pathname` option is optional in all cases for systems defined via `defsystem`, and in the usual case the user is recommended not to supply it. 

Instead, asdf follows a hairy set of rules that are designed so that 

  1. `find-system` will load a system from disk and have its pathname default to the right place 
  2. this pathname information will not be overwritten with `*default-pathname-defaults*` (which could be somewhere else altogether) if the user loads up the .asd file into his editor and interactively re-evaluates that form. 

If a system is being loaded for the first time, its top-level pathname will be set to: 

  * The host/device/directory parts of `*load-truename*`, if it is bound 
  * `*default-pathname-defaults*`, otherwise 

If a system is being redefined, the top-level pathname will be 

  * changed, if explicitly supplied or obtained from `*load-truename*` (so that an updated source location is reflected in the system definition) 
  * changed if it had previously been set from `*default-pathname-defaults*`
  * left as before, if it had previously been set from `*load-truename*` and `*load-truename*` is currently unbound (so that a developer can evaluate a `defsystem` form from within an editor without clobbering its source location) 

* * *

Previous: [The defsystem grammar][6], Up: [Defining systems with defsystem][3]

### 2.4 Other code in .asd files

Files containing defsystem forms are regular Lisp files that are executed by `load`. Consequently, you can put whatever Lisp code you like into these files (e.g., code that examines the compile-time environment and adds appropriate features to `*features*`). However, some conventions should be followed, so that users can control certain details of execution of the Lisp in .asd files: 

  * Any informative output (other than warnings and errors, which are the condition system's to dispose of) should be sent to the standard CL stream `*standard-output*`, so that users can easily control the disposition of output from asdf operations. 

* * *

Next: [Error handling][16], Previous: [Defining systems with defsystem][3], Up: [Top][1]

## 3 The object model of asdf

asdf is designed in an object-oriented way from the ground up. Both a system's structure and the operations that can be performed on systems follow a protocol. asdf is extensible to new operations and to new component types. This allows the addition of behaviours: for example, a new component could be added for Java JAR archives, and methods specialised on `compile-op` added for it that would accomplish the relevant actions. 

This chapter deals with _components_, the building blocks of a system, and _operations_, the actions that can be performed on a system. 

  * [Operations][9]
  * [Components][12]

* * *

Next: [Components][12], Previous: [The object model of asdf][8], Up: [The object model of asdf][8]

### 3.1 Operations

An operation object of the appropriate type is instantiated whenever the user wants to do something with a system like 

  * compile all its files 
  * load the files into a running lisp environment 
  * copy its source files somewhere else 

Operations can be invoked directly, or examined to see what their effects would be without performing them. _FIXME: document how!_ There are a bunch of methods specialised on operation and component type that actually do the grunt work. 

The operation object contains whatever state is relevant for this purpose (perhaps a list of visited nodes, for example) but primarily is a nice thing to specialise operation methods on and easier than having them all be EQL methods. 

Operations are invoked on systems via `operate`. 

-- Generic function: **operate** operation system &rest initargs  
-- Generic function: **oos** operation system &rest initargs  


> `operate` invokes operation on system. `oos` is a synonym for `operate`. 
> 
> operation is a symbol that is passed, along with the supplied initargs, to `make-instance` to create the operation object. system is a system designator. 
> 
> The initargs are passed to the `make-instance` call when creating the operation object. Note that dependencies may cause the operation to invoke other operations on the system or its components: the new operations will be created with the same initargs as the original one. 

  * [Predefined operations of asdf][10]
  * [Creating new operations][11]

* * *

Next: [Creating new operations][11], Previous: [Operations][9], Up: [Operations][9]

#### 3.1.1 Predefined operations of asdf

All the operations described in this section are in the `asdf` package. They are invoked via the `operate` generic function. 
    
         (asdf:operate 'asdf:operation-name 'system-name {operation-options ...})
    

-- Operation: **compile-op** &key proclamations  


> This operation compiles the specified component. If proclamations are supplied, they will be proclaimed. This is a good place to specify optimization settings. 
> 
> When creating a new component type, you should provide methods for `compile-op`. 
> 
> When `compile-op` is invoked, component dependencies often cause some parts of the system to be loaded as well as compiled. Invoking `compile-op` does not necessarily load all the parts of the system, though; use `load-op` to load a system. 

-- Operation: **load-op** &key proclamations  


> This operation loads a system. 
> 
> The default methods for `load-op` compile files before loading them. For parity, your own methods on new component types should probably do so too. 

-- Operation: **load-source-op**  


> This operation will load the source for the files in a module even if the source files have been compiled. Systems sometimes have knotty dependencies which require that sources are loaded before they can be compiled. This is how you do that. 
> 
> If you are creating a component type, you need to implement this operation - at least, where meaningful. 

-- Operation: **test-system-version** &key minimum  


> Asks the system whether it satisfies a version requirement. 
> 
> The default method accepts a string, which is expected to contain of a number of integers separated by #\. characters. The method is not recursive. The component satisfies the version dependency if it has the same major number as required and each of its sub-versions is greater than or equal to the sub-version number required. 
>     
>               (defun version-satisfies (x y)
>                 (labels ((bigger (x y)
>               	     (cond ((not y) t)
>               		   ((not x) nil)
>               		   ((> (car x) (car y)) t)
>               		   ((= (car x) (car y))
>               		    (bigger (cdr x) (cdr y))))))
>                   (and (= (car x) (car y))
>               	 (or (not (cdr y)) (bigger (cdr x) (cdr y))))))
>     
> 
> If that doesn't work for your system, you can override it. I hope you have as much fun writing the new method as #lisp did reimplementing this one. 

-- Operation: **feature-dependent-op**  


> An instance of `feature-dependent-op` will ignore any components which have a `features` attribute, unless the feature combination it designates is satisfied by `*features*`. This operation is not intended to be instantiated directly, but other operations may inherit from it. 

* * *

Previous: [Predefined operations of asdf][10], Up: [Operations][9]

#### 3.1.2 Creating new operations

asdf was designed to be extensible in an object-oriented fashion. To teach asdf new tricks, a programmer can implement the behaviour he wants by creating a subclass of `operation`. 

asdf's pre-defined operations are in no way "privileged", but it is requested that developers never use the `asdf` package for operations they develop themselves. The rationale for this rule is that we don't want to establish a "global asdf operation name registry", but also want to avoid name clashes. 

An operation must provide methods for the following generic functions when invoked with an object of type `source-file`: _FIXME describe this better_

  * `output-files`
  * `perform` The `perform` method must call `output-files` to find out where to put its files, because the user is allowed to override 
  * `output-files` for local policy `explain`
  * `operation-done-p`, if you don't like the default one 

Operations that print output should send that output to the standard CL stream `*standard-output*`, as the Lisp compiler and loader do. 

* * *

Previous: [Operations][9], Up: [The object model of asdf][8]

### 3.2 Components

A component represents a source file or (recursively) a collection of components. A system is (roughly speaking) a top-level component that can be found via `find-system`. 

A system designator is a string or symbol and behaves just like any other component name (including with regard to the case conversion rules for component names). 

-- Function: **find-system** system-designator &optional (error-p t)  


> Given a system designator, `find-system` finds and returns a system. If no system is found, an error of type `missing-component` is thrown, or `nil` is returned if `error-p` is false. 
> 
> To find and update systems, `find-system` funcalls each element in the `*system-definition-search-functions*` list, expecting a pathname to be returned. The resulting pathname is loaded if either of the following conditions is true: 
> 
>   * there is no system of that name in memory 
>   * the file's last-modified time exceeds the last-modified time of the system in memory 
> 
> When system definitions are loaded from .asd files, a new scratch package is created for them to load into, so that different systems do not overwrite each others operations. The user may also wish to (and is recommended to) include `defpackage` and `in-package` forms in his system definition files, however, so that they can be loaded manually if need be. 
> 
> The default value of `*system-definition-search-functions*` is a function that looks in each of the directories given by evaluating members of `*central-registry*` for a file whose name is the name of the system and whose type is asd. The first such file is returned, whether or not it turns out to actually define the appropriate system. Hence, it is strongly advised to define a system foo in the corresponding file foo.asd. 

  * [Common attributes of components][13]
  * [Pre-defined subclasses of component][14]
  * [Creating new component types][15]

* * *

Next: [Pre-defined subclasses of component][14], Previous: [Components][12], Up: [Components][12]

#### 3.2.1 Common attributes of components

All components, regardless of type, have the following attributes. All attributes except `name` are optional. 

##### 3.2.1.1 Name

A component name is a string or a symbol. If a symbol, its name is taken and lowercased. The name must be a suitable value for the `:name` initarg to `make-pathname` in whatever filesystem the system is to be found. 

The lower-casing-symbols behaviour is unconventional, but was selected after some consideration. Observations suggest that the type of systems we want to support either have lowercase as customary case (Unix, Mac, windows) or silently convert lowercase to uppercase (lpns), so this makes more sense than attempting to use `:case :common` as argument to `make-pathname`, which is reported not to work on some implementations 

##### 3.2.1.2 Version identifier

This optional attribute is used by the test-system-version operation. See [Predefined operations of asdf][10]. For the default method of test-system-version, the version should be a string of intergers separated by dots, for example '1.0.11'. 

##### 3.2.1.3 Required features

Traditionally defsystem users have used reader conditionals to include or exclude specific per-implementation files. This means that any single implementation cannot read the entire system, which becomes a problem if it doesn't wish to compile it, but instead for example to create an archive file containing all the sources, as it will omit to process the system-dependent sources for other systems. 

Each component in an asdf system may therefore specify features using the same syntax as #+ does, and it will (somehow) be ignored for certain operations unless the feature conditional is a member of `*features*`. 

##### 3.2.1.4 Dependencies

This attribute specifies dependencies of the component on its siblings. It is optional but often necessary. 

There is an excitingly complicated relationship between the initarg and the method that you use to ask about dependencies 

Dependencies are between (operation component) pairs. In your initargs for the component, you can say 
    
         :in-order-to ((compile-op (load-op "a" "b") (compile-op "c"))
         	      (load-op (load-op "foo")))
    

This means the following things: 

  * before performing compile-op on this component, we must perform load-op on a and b, and compile-op on c, 
  * before performing `load-op`, we have to load foo

The syntax is approximately 
    
    (this-op {(other-op required-components)}+)
    
    required-components := component-name
                         | (required-components required-components)
    
    component-name := string
                    | (:version string minimum-version-object)
    

Side note: 

This is on a par with what ACL defsystem does. mk-defsystem is less general: it has an implied dependency 
    
      for all x, (load x) depends on (compile x)
    

and using a `:depends-on` argument to say that b depends on a _actually_ means that 
    
      (compile b) depends on (load a) 
    

This is insufficient for e.g. the McCLIM system, which requires that all the files are loaded before any of them can be compiled ] 

End side note 

In asdf, the dependency information for a given component and operation can be queried using `(component-depends-on operation component)`, which returns a list 
    
         ((load-op "a") (load-op "b") (compile-op "c") ...)
    

`component-depends-on` can be subclassed for more specific component/operation types: these need to `(call-next-method)` and append the answer to their dependency, unless they have a good reason for completely overriding the default dependencies 

(If it weren't for CLISP, we'd be using a `LIST` method combination to do this transparently. But, we need to support CLISP. If you have the time for some CLISP hacking, I'm sure they'd welcome your fixes) 

##### 3.2.1.5 pathname

This attribute is optional and if absent will be inferred from the component's name, type (the subclass of source-file), and the location of its parent. 

The rules for this inference are: 

(for source-files) 

  * the host is taken from the parent 
  * pathname type is `(source-file-type component system)`
  * the pathname case option is `:local`
  * the pathname is merged against the parent 

(for modules) 

  * the host is taken from the parent 
  * the name and type are `NIL`
  * the directory is `(:relative component-name)`
  * the pathname case option is `:local`
  * the pathname is merged against the parent 

Note that the DEFSYSTEM operator (used to create a "top-level" system) does additional processing to set the filesystem location of the top component in that system. This is detailed elsewhere, See [Defining systems with defsystem][3]. 

The answer to the frequently asked question "how do I create a system definition where all the source files have a .cl extension" is thus 
    
         (defmethod source-file-type ((c cl-source-file) (s (eql (find-system 'my-sys))))
            "cl")
    

##### 3.2.1.6 properties

This attribute is optional. 

Packaging systems often require information about files or systems in addition to that specified by asdf's pre-defined component attributes. Programs that create vendor packages out of asdf systems therefore have to create "placeholder" information to satisfy these systems. Sometimes the creator of an asdf system may know the additional information and wish to provide it directly. 

(component-property component property-name) and associated setf method will allow the programmatic update of this information. Property names are compared as if by `EQL`, so use symbols or keywords or something. 

  * [Pre-defined subclasses of component][14]
  * [Creating new component types][15]

* * *

Next: [Creating new component types][15], Previous: [Common attributes of components][13], Up: [Components][12]

#### 3.2.2 Pre-defined subclasses of component

-- Component: **source-file**  


> A source file is any file that the system does not know how to generate from other components of the system. 
> 
> Note that this is not necessarily the same thing as "a file containing data that is typically fed to a compiler". If a file is generated by some pre-processor stage (e.g. a .h file from .h.in by autoconf) then it is not, by this definition, a source file. Conversely, we might have a graphic file that cannot be automatically regenerated, or a proprietary shared library that we received as a binary: these do count as source files for our purposes. 
> 
> Subclasses of source-file exist for various languages. _FIXME: describe these._

-- Component: **module**  


> A module is a collection of sub-components. 
> 
> A module component has the following extra initargs: 
> 
>   * `:components` the components contained in this module 
>   * `:default-component-class` All child components which don't specify their class explicitly are inferred to be of this type. 
>   * `:if-component-dep-fails` This attribute takes one of the values `:fail`, `:try-next`, `:ignore`, its default value is `:fail`. The other values can be used for implementing conditional compilation based on implementation `*features*`, for the case where it is not necessary for all files in a module to be compiled. 
>   * `:serial` When this attribute is set, each subcomponent of this component is assumed to depend on all subcomponents before it in the list given to `:components`, i.e. all of them are loaded before a compile or load operation is performed on it. 
> 
> The default operation knows how to traverse a module, so most operations will not need to provide methods specialised on modules. 
> 
> `module` may be subclassed to represent components such as foreign-language linked libraries or archive files. 

-- Component: **system**  


> `system` is a subclass of `module`. 
> 
> A system is a module with a few extra attributes for documentation purposes; these are given elsewhere. See [The defsystem grammar][6]. 
> 
> Users can create new classes for their systems: the default `defsystem` macro takes a `:classs` keyword argument. 

* * *

Previous: [Pre-defined subclasses of component][14], Up: [Components][12]

#### 3.2.3 Creating new component types

New component types are defined by subclassing one of the existing component classes and specializing methods on the new component class. 

_FIXME: this should perhaps be explained more throughly, not only by example ..._

As an example, suppose we have some implementation-dependent functionality that we want to isolate in one subdirectory per Lisp implementation our system supports. We create a subclass of `cl-source-file`: 
    
         (defclass unportable-cl-source-file (cl-source-file)
             ())
    

A hypothetical function `system-dependent-dirname` gives us the name of the subdirectory. All that's left is to define how to calculate the pathname of an `unportable-cl-source-file`. 
    
         (defmethod component-pathname ((component unportable-cl-source-file))
           (let ((pathname (call-next-method))
                 (name (string-downcase (system-dependent-dirname))))
             (merge-pathnames
              (make-pathname :directory (list :relative name))
              pathname)))
    

The new component type is used in a `defsystem` form in this way: 
    
         (defsystem :foo
             :components
             ((:file "packages")
              ...
              (:unportable-cl-source-file "threads"
               :depends-on ("packages" ...))
              ...
             )
    

* * *

Next: [Compilation error and warning handling][17], Previous: [The object model of asdf][8], Up: [Top][1]

## 4 Error handling

It is an error to define a system incorrectly: an implementation may detect this and signal a generalised instance of `SYSTEM-DEFINITION-ERROR`. 

Operations may go wrong (for example when source files contain errors). These are signalled using generalised instances of `OPERATION-ERROR`. 

* * *

Next: [Miscellaneous additional functionality][18], Previous: [Error handling][16], Up: [Top][1]

## 5 Compilation error and warning handling

ASDF checks for warnings and errors when a file is compiled. The variables `*compile-file-warnings-behaviour*` and `*compile-file-errors-behavior*` controls the handling of any such events. The valid values for these variables are `:error`, `:warn`, and `:ignore`. 

* * *

Next: [Getting the latest version][19], Previous: [Compilation error and warning handling][17], Up: [Top][1]

## 6 Additional Functionality

ASDF includes several additional features that are generally useful for system definition and development. These include: 

  1. system-relative-pathname 

It's often handy to locate a file relative to some system. The system-relative-pathname function meets this need. It takes two arguments: the name of a system and a relative pathname. It returns a pathname built from the location of the system's source file and the relative pathname. For example 
    
              > (asdf:system-relative-pathname 'cl-ppcre "regex.data")
              #P"/repository/other/cl-ppcre/regex.data"
    

* * *

Next: [TODO list][20], Previous: [Miscellaneous additional functionality][18], Up: [Top][1]

## 7 Getting the latest version

  1. Decide which version you want. HEAD is the newest version and usually OK, whereas RELEASE is for cautious people (e.g. who already have systems using asdf that they don't want broken), a slightly older version about which none of the HEAD users have complained. 
  2. Check it out from sourceforge cCLan CVS: 

cvs -d:pserver:anonymous@cvs.cclan.sourceforge.net:/cvsroot/cclan login

(no password: just press <Enter>) 

cvs -z3 -d:pserver:anonymous@cvs.cclan.sourceforge.net:/cvsroot/cclan co -r RELEASE asdf

or for the bleeding edge, instead 

cvs -z3 -d:pserver:anonymous@cvs.cclan.sourceforge.net:/cvsroot/cclan co -A asdf

If you are tracking the bleeding edge, you may want to subscribe to the cclan-commits mailing list (see [http://sourceforge.net/mail/?group_id=28536][31]) to receive commit messages and diffs whenever changes are made. 

For more CVS information, look at [http://sourceforge.net/cvs/?group_id=28536][32]. 

* * *

Next: [missing bits in implementation][21], Previous: [Getting the latest version][19], Up: [Top][1]

## 8 TODO list

* Outstanding spec questions, things to add 

** packaging systems 

*** manual page component? 

** style guide for .asd files 

You should either use keywords or be careful with the package that you evaluate defsystem forms in. Otherwise (defsystem partition ...) being read in the cl-user package will intern a cl-user:partition symbol, which will then collide with the partition:partition symbol. 

Actually there's a hairier packages problem to think about too. in-order-to is not a keyword: if you read defsystem forms in a package that doesn't use ASDF, odd things might happen 

** extending defsystem with new options 

You might not want to write a whole parser, but just to add options to the existing syntax. Reinstate parse-option or something akin 

** document all the error classes 

** what to do with compile-file failure 

Should check the primary return value from compile-file and see if that gets us any closer to a sensible error handling strategy 

** foreign files 

lift unix-dso stuff from db-sockets 

** Diagnostics 

A "dry run" of an operation can be made with the following form: 
    
         (traverse (make-instance '<operation-name>)
                   (find-system <system-name>)
                   'explain)
    

This uses unexported symbols. What would be a nice interface for this functionality? 

* * *

Next: [Inspiration][22], Previous: [TODO list][20], Up: [Top][1]

## 9 missing bits in implementation

** all of the above 

** reuse the same scratch package whenever a system is reloaded from disk 

** rules for system pathname defaulting are not yet implemented properly 

** proclamations probably aren't 

** when a system is reloaded with fewer components than it previously had, odd things happen 

we should do something inventive when processing a defsystem form, like take the list of kids and setf the slot to nil, then transfer children from old to new list as they're found 

** traverse may become a normal function 

If you're defining methods on traverse, speak up. 

** a lot of load-op methods can be rewritten to use input-files 

so should be. 

** (stuff that might happen later) 

*** david lichteblau's patch for symlink resolution? 

*** Propagation of the :force option. "I notice that 

(oos 'compile-op :araneida :force t) 

also forces compilation of every other system the :araneida system depends on. This is rarely useful to me; usually, when I want to force recompilation of something more than a single source file, I want to recompile only one system. So it would be more useful to have make-sub-operation refuse to propagate `:force t` to other systems, and propagate only something like `:force :recursively`. 

Ideally what we actually want is some kind of criterion that says to which systems (and which operations) a `:force` switch will propagate. 

The problem is perhaps that `force' is a pretty meaningless concept. How obvious is it that `load :force t` should force _compilation_? But we don't really have the right dependency setup for the user to compile `:force t` and expect it to work (files will not be loaded after compilation, so the compile environment for subsequent files will be emptier than it needs to be) 

What does the user actually want to do when he forces? Usually, for me, update for use with a new version of the lisp compiler. Perhaps for recovery when he suspects that something has gone wrong. Or else when he's changed compilation options or configuration in some way that's not reflected in the dependency graph. 

Other possible interface: have a 'revert' function akin to 'make clean' 
    
         (asdf:revert 'asdf:compile-op 'araneida)
    

would delete any files produced by 'compile-op 'araneida. Of course, it wouldn't be able to do much about stuff in the image itself. 

How would this work? 

traverse 

There's a difference between a module's dependencies (peers) and its components (children). Perhaps there's a similar difference in operations? For example, `(load "use") depends-on (load "macros")` is a peer, whereas `(load "use") depends-on (compile "use")` is more of a `subservient' relationship. 

* * *

Next: [Concept Index][23], Previous: [missing bits in implementation][21], Up: [Top][1]

## 10 Inspiration

### 10.1 mk-defsystem (defsystem-3.x)

We aim to solve basically the same problems as mk-defsystem does. However, our architecture for extensibility better exploits CL language features (and is documented), and we intend to be portable rather than just widely-ported. No slight on the mk-defsystem authors and maintainers is intended here; that implementation has the unenviable task of supporting pre-ANSI implementations, which is no longer necessary. 

The surface defsystem syntax of asdf is more-or-less compatible with mk-defsystem, except that we do not support the `source-foo` and `binary-foo` prefixes for separating source and binary files, and we advise the removal of all options to specify pathnames. 

The mk-defsystem code for topologically sorting a module's dependency list was very useful. 

### 10.2 defsystem-4 proposal

Marco and Peter's proposal for defsystem 4 served as the driver for many of the features in here. Notable differences are: 

  * We don't specify output files or output file extensions as part of the system. 

If you want to find out what files an operation would create, ask the operation. 
  * We don't deal with CL packages 

If you want to compile in a particular package, use an in-package form in that file (ilisp / SLIME will like you more if you do this anyway) 
  * There is no proposal here that defsystem does version control. 

A system has a given version which can be used to check dependencies, but that's all. 

The defsystem 4 proposal tends to look more at the external features, whereas this one centres on a protocol for system introspection. 

### 10.3 kmp's "The Description of Large Systems", MIT AI Memu 801

Available in updated-for-CL form on the web at [http://world.std.com/~pitman/Papers/Large-Systems.html][33]

In our implementation we borrow kmp's overall PROCESS-OPTIONS and concept to deal with creating component trees from defsystem surface syntax. [ this is not true right now, though it used to be and probably will be again soon ] 

* * *

Next: [Function and Class Index][24], Previous: [Inspiration][22], Up: [Top][1]

## Concept Index

  * [component][34]: [Components][12]
  * [operation][35]: [Operations][9]
  * [system][36]: [Components][12]
  * [system designator][37]: [Components][12]
  * [system directory designator][38]: [Using asdf to load systems][2]

* * *

Next: [Variable Index][25], Previous: [Concept Index][23], Up: [Top][1]

## Function and Class Index

  * [`compile-op`][39]: [Predefined operations of asdf][10]
  * [`feature-dependent-op`][40]: [Predefined operations of asdf][10]
  * [`find-system`][41]: [Components][12]
  * [`load-op`][42]: [Predefined operations of asdf][10]
  * [`load-source-op`][43]: [Predefined operations of asdf][10]
  * [`module`][44]: [Pre-defined subclasses of component][14]
  * [`oos`][45]: [Operations][9]
  * [`operate`][46]: [Operations][9]
  * [`OPERATION-ERROR`][47]: [Error handling][16]
  * [`source-file`][48]: [Pre-defined subclasses of component][14]
  * [`system`][49]: [Pre-defined subclasses of component][14]
  * [`SYSTEM-DEFINITION-ERROR`][50]: [Error handling][16]
  * [`test-system-version`][51]: [Predefined operations of asdf][10]

* * *

Previous: [Function and Class Index][24], Up: [Top][1]

## Variable Index

  * [`*central-registry*`][52]: [Using asdf to load systems][2]
  * [`*compile-file-errors-behavior*`][53]: [Compilation error and warning handling][17]
  * [`*compile-file-warnings-behaviour*`][54]: [Compilation error and warning handling][17]
  * [`*system-definition-search-functions*`][55]: [Components][12]

* * *

#### Footnotes

{footnotes}

* * *

   [1]: #Top
   [2]: #Using-asdf-to-load-systems
   [3]: #Defining-systems-with-defsystem
   [4]: #The-defsystem-form
   [5]: #A-more-involved-example
   [6]: #The-defsystem-grammar
   [7]: #Other-code-in-_002easd-files
   [8]: #The-object-model-of-asdf
   [9]: #Operations
   [10]: #Predefined-operations-of-asdf
   [11]: #Creating-new-operations
   [12]: #Components
   [13]: #Common-attributes-of-components
   [14]: #Pre_002ddefined-subclasses-of-component
   [15]: #Creating-new-component-types
   [16]: #Error-handling
   [17]: #Compilation-error-and-warning-handling
   [18]: #Miscellaneous-additional-functionality
   [19]: #Getting-the-latest-version
   [20]: #TODO-list
   [21]: #missing-bits-in-implementation
   [22]: #Inspiration
   [23]: #Concept-Index
   [24]: #Function-and-Class-Index
   [25]: #Variable-Index
   [26]: #dir
   [27]: http://cvs.sourceforge.net/cgi-bin/viewcvs.cgi/cclan/asdf/
   [28]: #fn-1
   [29]: #fn-2
   [30]: #fn-3
   [31]: http://sourceforge.net/mail/?group_id=28536
   [32]: http://sourceforge.net/cvs/?group_id=28536
   [33]: http://world.std.com/~pitman/Papers/Large-Systems.html
   [34]: #index-component-11
   [35]: #index-operation-3
   [36]: #index-system-12
   [37]: #index-system-designator-13
   [38]: #index-system-directory-designator-1
   [39]: #index-compile_002dop-6
   [40]: #index-feature_002ddependent_002dop-10
   [41]: #index-find_002dsystem-15
   [42]: #index-load_002dop-7
   [43]: #index-load_002dsource_002dop-8
   [44]: #index-module-17
   [45]: #index-oos-5
   [46]: #index-operate-4
   [47]: #index-OPERATION_002dERROR-20
   [48]: #index-source_002dfile-16
   [49]: #index-system-18
   [50]: #index-SYSTEM_002dDEFINITION_002dERROR-19
   [51]: #index-test_002dsystem_002dversion-9
   [52]: #index-g_t_002acentral_002dregistry_002a-2
   [53]: #index-g_t_002acompile_002dfile_002derrors_002dbehavior_002a-22
   [54]: #index-g_t_002acompile_002dfile_002dwarnings_002dbehaviour_002a-21
   [55]: #index-g_t_002asystem_002ddefinition_002dsearch_002dfunctions_002a-14
   
</div>
{include resources/footer.md}
</div>



