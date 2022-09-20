class JSFlags {
  /* flags for object properties */
  static const JS_PROP_CONFIGURABLE = 1 << 0;
  static const JS_PROP_WRITABLE = 1 << 1;
  static const JS_PROP_ENUMERABLE = 1 << 2;
  static const JS_PROP_C_W_E =
      JS_PROP_CONFIGURABLE | JS_PROP_WRITABLE | JS_PROP_ENUMERABLE;
  static const JS_PROP_LENGTH = 1 << 3; /* used internally in Arrays */
  static const JS_PROP_TMASK =
      3 << 4; /* mask for NORMAL, GETSET, VARREF, AUTOINIT */
  static const JS_PROP_NORMAL = 0 << 4;
  static const JS_PROP_GETSET = 1 << 4;
  static const JS_PROP_VARREF = 2 << 4;
  static const JS_PROP_AUTOINIT = 3 << 4;

  /* flags for JS_DefineProperty */
  static const JS_PROP_HAS_SHIFT = 8;
  static const JS_PROP_HAS_CONFIGURABLE = 1 << 8;
  static const JS_PROP_HAS_WRITABLE = 1 << 9;
  static const JS_PROP_HAS_ENUMERABLE = 1 << 10;
  static const JS_PROP_HAS_GET = 1 << 11;
  static const JS_PROP_HAS_SET = 1 << 12;
  static const JS_PROP_HAS_VALUE = 1 << 13;

  /* throw an exception if false would be returned
  (JS_DefineProperty/JS_SetProperty) */
  static const JS_PROP_THROW = 1 << 14;
  /* throw an exception if false would be returned in strict mode
  (JS_SetProperty) */
  static const JS_PROP_THROW_STRICT = 1 << 15;

  static const JS_PROP_NO_ADD = 1 << 16; /* internal use */
  static const JS_PROP_NO_EXOTIC = 1 << 17; /* internal use */

  static const JS_DEFAULT_STACK_SIZE = 256 * 1024;

  /* JS_Eval() flags */
  static const JS_EVAL_TYPE_GLOBAL = 0 << 0; /* global code (default) */
  static const JS_EVAL_TYPE_MODULE = 1 << 0; /* module code */
  static const JS_EVAL_TYPE_DIRECT = 2 << 0; /* direct call (internal use) */
  static const JS_EVAL_TYPE_INDIRECT =
      3 << 0; /* indirect call (internal use) */
  static const JS_EVAL_TYPE_MASK = 3 << 0;

  static const JS_EVAL_FLAG_STRICT = 1 << 3; /* force 'strict' mode */
  static const JS_EVAL_FLAG_STRIP = 1 << 4; /* force 'strip' mode */

  /* compile but do not run. The result is an object with a
   JS_TAG_FUNCTION_BYTECODE or JS_TAG_MODULE tag. It can be executed
   with JS_EvalFunction(). */
  static const JS_EVAL_FLAG_COMPILE_ONLY = 1 << 5;
  /* don't include the stack frames before this eval in the Error() backtraces */
  static const JS_EVAL_FLAG_BACKTRACE_BARRIER = 1 << 6;
}
