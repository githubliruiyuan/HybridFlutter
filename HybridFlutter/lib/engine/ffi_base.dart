import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'ffi_helpers.dart';

///////////////////////////////////////////////////////////////////////////////
// Typedef's
///////////////////////////////////////////////////////////////////////////////

/// typedef struct JSRuntime JSRuntime;
class JSRuntime extends Opaque {}

/// typedef struct JSContext JSContext;
class JSContext extends Opaque {}

/// typedef struct JSClass JSClass;
class JSClass extends Opaque {}

// typefdef struct JSValueConst
class JSValueConst extends Opaque {}

/// JSValue has complex defined in C apis. we use here to identify the datatype only with dart
/// class JSValue extends Struct {}

/// JSRuntime *JS_NewRuntime(void);
typedef newRuntimeFunc = Pointer<JSRuntime> Function();
typedef newRuntimeNative = Pointer<JSRuntime> Function();
final newRuntimeName = "newRuntime";
final newRuntimeFunc newRuntime =
    dylib.lookup<NativeFunction<newRuntimeNative>>(newRuntimeName).asFunction();

/// info lifetime must exceed that of rt
/// void JS_SetRuntimeInfo(JSRuntime *rt, const char *info);
typedef setRuntimeInfoFunc = void Function(
    Pointer<JSRuntime> rt, Pointer<Utf8> info);
typedef setRuntimeInfoNative = Void Function(Pointer, Pointer);
final setRuntimeInfoName = "JS_SetRuntimeInfo";
final setRuntimeInfoFunc setupRuntimeInfo = dylib
    .lookup<NativeFunction<setRuntimeInfoNative>>(setRuntimeInfoName)
    .asFunction();

/// void JS_SetMemoryLimit(JSRuntime *rt, size_t limit);
typedef setMemoryLimitFunc = void Function(Pointer<JSRuntime> rt, int limit);
typedef setMemoryLimitNative = Void Function(Pointer<JSRuntime>, IntPtr);
final setMemoryLimitName = "JS_SetMemoryLimit";
final setMemoryLimitFunc setupRuntimeLimit = dylib
    .lookup<NativeFunction<setMemoryLimitNative>>(setMemoryLimitName)
    .asFunction();

/// void JS_SetGCThreshold(JSRuntime *rt, size_t gc_threshold);
typedef setGCThresholdFunc = void Function(
    Pointer<JSRuntime> rt, int gcThreshold);
typedef setGCThresholdNative = Void Function(Pointer<JSRuntime>, IntPtr);
final setGCThresholdName = "JS_SetGCThreshold";
final setGCThresholdFunc setGCThreshold = dylib
    .lookup<NativeFunction<setGCThresholdNative>>(setGCThresholdName)
    .asFunction();

/// void JS_SetMaxStackSize(JSRuntime *rt, size_t stack_size);
typedef setMaxStackSizeFunc = void Function(
    Pointer<JSRuntime> rt, int stackSize);
typedef setMaxStackSizeNative = Void Function(Pointer<JSRuntime>, IntPtr);
final setMaxStackSizeName = "JS_SetMaxStackSize";
final setMaxStackSizeFunc setMaxStackSize = dylib
    .lookup<NativeFunction<setMaxStackSizeNative>>(setMaxStackSizeName)
    .asFunction();

/// JSRuntime *JS_NewRuntime2(const JSMallocFunctions *mf, void *opaque);
// typedef newRuntime2Func = void Function(Pointer<JSRuntime>, void);
// typedef newRuntime2Native = Void Function(Pointer<JSRuntime>, Void);
// final newRuntime2Name = "JS_NewRuntime2";
// final newRuntime2Func newRuntime2 = dylib
//     .lookup<NativeFunction<newRuntime2Native>>(newRuntime2Name)
//     .asFunction();

/// void JS_FreeRuntime(JSRuntime *rt);
typedef freeRuntimeFunc = void Function(Pointer<JSRuntime> rt);
typedef freeRuntimeNative = Void Function(Pointer<JSRuntime>);
final freeRuntimeName = "JS_SetMaxStackSize";
final freeRuntimeFunc freeRuntime = dylib
    .lookup<NativeFunction<freeRuntimeNative>>(freeRuntimeName)
    .asFunction();

/// void *JS_GetRuntimeOpaque(JSRuntime *rt);
typedef getRuntimeOpaqueFunc = void Function(Pointer<JSRuntime> rt);
typedef getRuntimeOpaqueNative = Void Function(Pointer<JSRuntime>);
final getRuntimeOpaqueName = "JS_GetRuntimeOpaque";
final getRuntimeOpaqueFunc getRuntimeOpaque = dylib
    .lookup<NativeFunction<getRuntimeOpaqueNative>>(getRuntimeOpaqueName)
    .asFunction();

/// void JS_SetRuntimeOpaque(JSRuntime *rt, void *opaque); ????? void *
typedef setRuntimeOpaqueFunc = void Function(
    Pointer<JSRuntime> rt, void opaque);
typedef setRuntimeOpaqueNative = Void Function(Pointer<JSRuntime>, Void);

// final setRuntimeOpaqueName = "JS_SetRuntimeOpaque";
// final setRuntimeOpaqueFunc setRuntimeOpaque = dylib
//     .lookup<NativeFunction<setRuntimeOpaqueNative>>(setRuntimeOpaqueName)
//     .asFunction();

/// typedef void JS_MarkFunc(JSRuntime *rt, JSGCObjectHeader *gp);
// void JS_MarkValue(JSRuntime *rt, JSValueConst val, JS_MarkFunc *markFunc);

/// void JS_RunGC(JSRuntime *rt);
typedef runGCFunc = void Function(Pointer<JSRuntime> rt);
typedef runGCNative = Void Function(Pointer<JSRuntime>);
final runGCName = "JS_RunGC";
final runGCFunc runGC =
    dylib.lookup<NativeFunction<runGCNative>>(runGCName).asFunction();

// JS_BOOL JS_IsLiveObject(JSRuntime *rt, JSValueConst obj);

/// JSContext *JS_NewContext(JSRuntime *rt);
typedef newContextFunc = Pointer<JSContext> Function(Pointer<JSRuntime> rt);
typedef newContextNative = Pointer<JSContext> Function(Pointer<JSRuntime>);
final newContextName = "newContext";
final newContextFunc newContext =
    dylib.lookup<NativeFunction<newContextNative>>(newContextName).asFunction();

/// void JS_FreeContext(JSContext *s);
typedef freeContextFunc = void Function(Pointer<JSContext> s);
typedef freeContextNative = Void Function(Pointer<JSContext>);
final freeContextName = "JS_FreeContext";
final freeContextFunc freeContext = dylib
    .lookup<NativeFunction<freeContextNative>>(freeContextName)
    .asFunction();

/// JSContext *JS_DupContext(JSContext *ctx);
typedef dupContextFunc = Pointer<JSContext> Function(Pointer<JSContext> ctx);
typedef dupContextNative = Pointer<JSContext> Function(Pointer<JSContext>);
final dupContextName = "JS_DupContext";
final dupContextFunc dupContext =
    dylib.lookup<NativeFunction<dupContextNative>>(dupContextName).asFunction();

/// void *JS_GetContextOpaque(JSContext *ctx);
typedef getContextOpaqueFunc = Pointer<void> Function(Pointer<JSContext> ctx);
typedef getContextOpaqueNative = Pointer<Void> Function(Pointer<JSContext> ctx);
final getContextOpaqueName = "JS_GetContextOpaque";
final getContextOpaqueFunc getContextOpaque = dylib
    .lookup<NativeFunction<getContextOpaqueNative>>(getContextOpaqueName)
    .asFunction();

/// void JS_SetContextOpaque(JSContext *ctx, void *opaque);
typedef setContextOpaqueFunc = Pointer<void> Function(Pointer<JSContext> ctx);
typedef setContextOpaqueNative = Pointer<Void> Function(Pointer<JSContext> ctx);
final setContextOpaqueName = "JS_SetContextOpaque";
final setContextOpaqueFunc setContextOpaque = dylib
    .lookup<NativeFunction<setContextOpaqueNative>>(setContextOpaqueName)
    .asFunction();

/// JSRuntime *JS_GetRuntime(JSContext *ctx);
typedef getRuntimeFunc = Pointer<JSRuntime> Function(Pointer<JSContext> ctx);
typedef getRuntimeNative = Pointer<JSRuntime> Function(Pointer<JSContext>);
final getRuntimeName = "JS_GetRuntime";
final getRuntimeFunc getRuntime =
    dylib.lookup<NativeFunction<getRuntimeNative>>(getRuntimeName).asFunction();

/// JSValue JS_GetClassProto(JSContext *ctx, JSClassID class_id);
typedef getClassProtoFunc = Pointer Function(
    Pointer<JSContext> ctx, int classId);
typedef getClassProtoNative = Pointer Function(Pointer<JSContext>, Uint32);
final getClassProtoName = "JS_SetClassProto";
final getClassProtoFunc getClassProto = dylib
    .lookup<NativeFunction<getClassProtoNative>>(getClassProtoName)
    .asFunction();

/// JSContext *JS_NewContextRaw(JSRuntime *rt);
typedef newContextRawFunc = Pointer<JSContext> Function(Pointer<JSRuntime> rt);
typedef newContextRawNative = Pointer<JSContext> Function(Pointer<JSRuntime>);
final newContextRawName = "JS_NewContextRaw";
final newContextRawFunc newContextRaw = dylib
    .lookup<NativeFunction<newContextRawNative>>(newContextRawName)
    .asFunction();

/// void JS_AddIntrinsicBaseObjects(JSContext *ctx);
typedef addIntrinsicBaseObjectsFunc = void Function(Pointer<JSContext> ctx);
typedef addIntrinsicBaseObjectsNative = Void Function(Pointer<JSContext>);
final addIntrinsicBaseObjectsName = "JS_AddIntrinsicBaseObjects";
final addIntrinsicBaseObjectsFunc addIntrinsicBaseObjects = dylib
    .lookup<NativeFunction<addIntrinsicBaseObjectsNative>>(
        addIntrinsicBaseObjectsName)
    .asFunction();

/// void JS_AddIntrinsicDate(JSContext *ctx);
typedef addIntrinsicDateFunc = void Function(Pointer<JSContext> ctx);
typedef addIntrinsicDateNative = Void Function(Pointer<JSContext>);
final addIntrinsicDateName = "JS_AddIntrinsicDate";
final addIntrinsicDateFunc addIntrinsicDate = dylib
    .lookup<NativeFunction<addIntrinsicDateNative>>(addIntrinsicDateName)
    .asFunction();

/// void JS_AddIntrinsicEval(JSContext *ctx);
typedef addIntrinsicEvalFunc = void Function(Pointer<JSContext> ctx);
typedef addIntrinsicEvalNative = Void Function(Pointer<JSContext>);
final addIntrinsicEvalName = "JS_AddIntrinsicEval";
final addIntrinsicEvalFunc addIntrinsicEval = dylib
    .lookup<NativeFunction<addIntrinsicEvalNative>>(addIntrinsicEvalName)
    .asFunction();

/// void JS_AddIntrinsicStringNormalize(JSContext *ctx);
typedef addIntrinsicStringNormalizeFunc = void Function(Pointer<JSContext> ctx);
typedef addIntrinsicStringNormalizeNative = Void Function(Pointer<JSContext>);
final addIntrinsicStringNormalizeName = "JS_AddIntrinsicStringNormalize";
final addIntrinsicStringNormalizeFunc addIntrinsicStringNormalize = dylib
    .lookup<NativeFunction<addIntrinsicStringNormalizeNative>>(
        addIntrinsicStringNormalizeName)
    .asFunction();

/// void JS_AddIntrinsicRegExpCompiler(JSContext *ctx);
typedef addIntrinsicRegExpCompilerFunc = void Function(Pointer<JSContext> ctx);
typedef addIntrinsicRegExpCompilerNative = Void Function(Pointer<JSContext>);
final addIntrinsicRegExpCompilerName = "JS_AddIntrinsicRegExpCompiler";
final addIntrinsicRegExpCompilerFunc addIntrinsicRegExpCompiler = dylib
    .lookup<NativeFunction<addIntrinsicRegExpCompilerNative>>(
        addIntrinsicRegExpCompilerName)
    .asFunction();

/// void JS_AddIntrinsicRegExp(JSContext *ctx);
typedef addIntrinsicRegExpFunc = void Function(Pointer<JSContext> ctx);
typedef addIntrinsicRegExpNative = Void Function(Pointer<JSContext>);
final addIntrinsicRegExpName = "JS_AddIntrinsicRegExpCompiler";
final addIntrinsicRegExpFunc addIntrinsicRegExp = dylib
    .lookup<NativeFunction<addIntrinsicRegExpNative>>(addIntrinsicRegExpName)
    .asFunction();

/// void JS_AddIntrinsicJSON(JSContext *ctx);
typedef addIntrinsicJSONFunc = void Function(Pointer<JSContext> ctx);
typedef addIntrinsicJSONNative = Void Function(Pointer<JSContext>);
final addIntrinsicJSONName = "JS_AddIntrinsicJSON";
final addIntrinsicJSONFunc addIntrinsicJSON = dylib
    .lookup<NativeFunction<addIntrinsicJSONNative>>(addIntrinsicJSONName)
    .asFunction();

/// void JS_AddIntrinsicProxy(JSContext *ctx);
typedef addIntrinsicProxyFunc = void Function(Pointer<JSContext> ctx);
typedef addIntrinsicProxyNative = Void Function(Pointer<JSContext>);
final addIntrinsicProxyName = "JS_AddIntrinsicProxy";
final addIntrinsicProxyFunc addIntrinsicProxy = dylib
    .lookup<NativeFunction<addIntrinsicProxyNative>>(addIntrinsicProxyName)
    .asFunction();

/// void JS_AddIntrinsicMapSet(JSContext *ctx);
typedef addIntrinsicMapSetFunc = void Function(Pointer<JSContext> ctx);
typedef addIntrinsicMapSetNative = Void Function(Pointer<JSContext>);
final addIntrinsicMapSetName = "JS_AddIntrinsicMapSet";
final addIntrinsicMapSetFunc addIntrinsicMapSet = dylib
    .lookup<NativeFunction<addIntrinsicMapSetNative>>(addIntrinsicMapSetName)
    .asFunction();

/// void JS_AddIntrinsicTypedArrays(JSContext *ctx);
typedef addIntrinsicTypedArraysFunc = void Function(Pointer<JSContext> ctx);
typedef addIntrinsicTypedArraysNative = Void Function(Pointer<JSContext>);
final addIntrinsicTypedArraysName = "JS_AddIntrinsicTypedArrays";
final addIntrinsicTypedArraysFunc addIntrinsicTypedArrays = dylib
    .lookup<NativeFunction<addIntrinsicTypedArraysNative>>(
        addIntrinsicTypedArraysName)
    .asFunction();

/// void JS_AddIntrinsicPromise(JSContext *ctx);
typedef addIntrinsicPromiseFunc = void Function(Pointer<JSContext> ctx);
typedef addIntrinsicPromiseNative = Void Function(Pointer<JSContext>);
final addIntrinsicPromiseName = "JS_AddIntrinsicPromise";
final addIntrinsicPromiseFunc addIntrinsicPromise = dylib
    .lookup<NativeFunction<addIntrinsicPromiseNative>>(addIntrinsicPromiseName)
    .asFunction();

/// void JS_AddIntrinsicBigInt(JSContext *ctx);
typedef addIntrinsicBigIntFunc = void Function(Pointer<JSContext> ctx);
typedef addIntrinsicBigIntNative = Void Function(Pointer<JSContext>);
final addIntrinsicBigIntName = "JS_AddIntrinsicBigInt";
final addIntrinsicBigIntFunc addIntrinsicBigInt = dylib
    .lookup<NativeFunction<addIntrinsicBigIntNative>>(addIntrinsicBigIntName)
    .asFunction();

/// void JS_AddIntrinsicBigFloat(JSContext *ctx);
typedef addIntrinsicBigFloatFunc = void Function(Pointer<JSContext> ctx);
typedef addIntrinsicBigFloatNative = Void Function(Pointer<JSContext>);
final addIntrinsicBigFloatName = "JS_AddIntrinsicBigFloat";
final addIntrinsicBigFloatFunc addIntrinsicBigFloat = dylib
    .lookup<NativeFunction<addIntrinsicBigFloatNative>>(
        addIntrinsicBigFloatName)
    .asFunction();

/// void JS_AddIntrinsicBigDecimal(JSContext *ctx);
typedef addIntrinsicBigDecimalFunc = void Function(Pointer<JSContext> ctx);
typedef addIntrinsicBigDecimalNative = Void Function(Pointer<JSContext>);
final addIntrinsicBigDecimalName = "JS_AddIntrinsicBigDecimal";
final addIntrinsicBigDecimalFunc addIntrinsicBigDecimal = dylib
    .lookup<NativeFunction<addIntrinsicBigDecimalNative>>(
        addIntrinsicBigDecimalName)
    .asFunction();

/// enable operator overloading
/// void JS_AddIntrinsicOperators(JSContext *ctx);
typedef addIntrinsicOperatorsFunc = void Function(Pointer<JSContext> ctx);
typedef addIntrinsicOperatorsNative = Void Function(Pointer<JSContext>);
final addIntrinsicOperatorsName = "JS_AddIntrinsicOperators";
final addIntrinsicOperatorsFunc addIntrinsicOperators = dylib
    .lookup<NativeFunction<addIntrinsicOperatorsNative>>(
        addIntrinsicOperatorsName)
    .asFunction();

/// enable "use math"
/// void JS_EnableBignumExt(JSContext *ctx, JS_BOOL enable);
typedef enableBignumExtFunc = void Function(Pointer<JSContext> ctx, int enable);
typedef enableBignumExtNative = Void Function(Pointer<JSContext>, Int32);
final enableBignumExtName = "JS_EnableBignumExt";
final enableBignumExtFunc enableBignumExt = dylib
    .lookup<NativeFunction<enableBignumExtNative>>(enableBignumExtName)
    .asFunction();

/// JSValue *eval(JSContext *ctx, const char *input, size_t input_len);
typedef evalFunc = Pointer Function(
    Pointer<JSContext> ctx, Pointer script, int length);
typedef evalNative = Pointer Function(
    Pointer<JSContext> ctx, Pointer script, Int32 length);
final evalName = "eval";

/// To eval a piece of javascript string, and return JSValue Pointer
/// ```dart
/// eval(JSContext ctx, Utf8Fix.toUtf8("${jsString}"), jsString.length)
/// ```
///
final evalFunc eval =
    dylib.lookup<NativeFunction<evalNative>>(evalName).asFunction();

/// JSValue invoke(JSContext *ctx, JSValueConst *this_val, uint_32 atom,
///                   int argc, JSValueConst *argv);
typedef invokeFunc = Pointer Function(Pointer<JSContext> ctx, Pointer thisVal,
    Pointer atom, int argc, Pointer<Pointer> argv);
typedef invokeNative = Pointer Function(Pointer<JSContext> ctx, Pointer thisVal,
    Pointer atom, Int32 argc, Pointer<Pointer> argv);

final invokeName = "invoke";

/// To invoke a JS_Object, pass with atom, argc,argv;
final invokeFunc invoke =
    dylib.lookup<NativeFunction<invokeNative>>(invokeName).asFunction();

/// JSValue call(JSContext *ctx, JSValueConst *func_obj, JSValueConst *this_obj,
///             int argc, JSValueConst *argv)
typedef callFunc = Pointer Function(Pointer<JSContext> ctx, Pointer funcObj,
    Pointer thisVal, int argc, Pointer<Pointer> argv);
typedef callNative = Pointer Function(Pointer<JSContext> ctx, Pointer funcObj,
    Pointer thisVal, Int32 argc, Pointer<Pointer> argv);

final callName = "call";

/// To invoke a JS_Object, pass with atom, argc,argv;
final callFunc call =
    dylib.lookup<NativeFunction<callNative>>(callName).asFunction();

// DART_EXTERN_C JSValue *dart_call_js(JSContext *ctx, JSValueConst *func_obj, JSValueConst *this_obj, int argc, JSValueConst **argv_ptrs)
typedef dart_call_jsFunc = Pointer Function(Pointer<JSContext> ctx,
    Pointer funcObj, Pointer thisVal, int argc, Pointer<Pointer> argv);
typedef dart_call_jsNative = Pointer Function(Pointer<JSContext> ctx,
    Pointer funcObj, Pointer thisVal, Int32 argc, Pointer<Pointer> argv);

final dartCallJSName = "dart_call_js";

/// To invoke a JS_Object, pass with atom, argc,argv;
final dart_call_jsFunc dartCallJS = dylib
    .lookup<NativeFunction<dart_call_jsNative>>(dartCallJSName)
    .asFunction();

/// JSValue *evalFunction(JSContext *ctx, JSValue *fun_obj);
typedef evalFunctionFunc = Pointer Function(Pointer ctx, Pointer funcObj);
typedef evalFunctionNative = Pointer Function(Pointer ctx, Pointer funcObj);

final evalFunctionName = "evalFunction";
final evalFunctionFunc evalFunction = dylib
    .lookup<NativeFunction<evalFunctionNative>>(evalFunctionName)
    .asFunction();

/// DART_EXTERN_C void installDartHook(JSContext *ctx, JSValueConst *this_val, JSValueConst *funcName, JSValue* fun_data)
typedef installDartHookFunc = void Function(
    Pointer<JSContext> ctx, Pointer thisVal, Pointer funcName, int funcId);
typedef installDartHookNative = Void Function(
    Pointer<JSContext> ctx, Pointer thisVal, Pointer funcName, Int64 funcId);
final installDartHookName = "installDartHook";
final installDartHookFunc installDartHook = dylib
    .lookup<NativeFunction<installDartHookNative>>(installDartHookName)
    .asFunction();

final registerDartCallbackFP =
    dylib.lookupFunction<Void Function(Pointer), void Function(Pointer)>(
        "RegisterDartCallbackFP");

// DART_EXTERN_C int isJobPending(JSRuntime *rt)
final isJobPending = dylib.lookupFunction<Int32 Function(Pointer<JSRuntime>),
    int Function(Pointer<JSRuntime>)>('isJobPending');

// DART_EXTERN_C JSValue *executePendingJob(JSRuntime *rt, int maxJobsToExecute)
final executePendingJob = dylib.lookupFunction<
    Pointer Function(Pointer<JSRuntime>, Int32),
    Pointer Function(Pointer<JSRuntime>, int)>('executePendingJob');

// DART_EXTERN_C JSValue *newPromiseCapability(JSContext *ctx, JSValue **resolveFuncs_out)
final newPromiseCapability = dylib.lookupFunction<
    Pointer Function(Pointer<JSContext>, Pointer<Pointer>),
    Pointer Function(
        Pointer<JSContext>, Pointer<Pointer>)>('newPromiseCapability');
