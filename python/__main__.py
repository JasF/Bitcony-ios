from rubicon.objc import ObjCClass
print('Hello Python on iOS!')
HelloRubicon = ObjCClass("HelloRubicon")
NSURL = ObjCClass("NSURL")
base = NSURL.URLWithString("http://pybee.org/")
print(base)
obj = HelloRubicon.alloc().init();
print(obj)
