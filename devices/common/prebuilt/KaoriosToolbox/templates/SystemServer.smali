.class public final Lcom/android/server/SystemServer;
.super Ljava/lang/Object;

.method private run()V
    .registers 19

    move-object/from16 v1, p0

    const-string/jumbo v0, "persist.sys.language"

    const-string v2, ""

    const-string v3, "SystemServer"

    new-instance v4, Lcom/android/server/utils/TimingsTraceAndSlog;

    invoke-direct {v4}, Lcom/android/server/utils/TimingsTraceAndSlog;-><init>()V

    :try_start_e
    invoke-static {}, Landroid/tracing/Flags;->systemServerLargePerfettoShmemBuffer()Z

    move-result v5

    if-eqz v5, :cond_1f

    new-instance v5, Landroid/tracing/perfetto/InitArguments;

    const/4 v6, 0x2

    const/16 v7, 0x1000

    invoke-direct {v5, v6, v7}, Landroid/tracing/perfetto/InitArguments;-><init>(II)V

    invoke-static {v5}, Landroid/tracing/perfetto/Producer;->init(Landroid/tracing/perfetto/InitArguments;)V

    :cond_1f
    const-string v5, "InitBeforeStartServices"

    invoke-virtual {v4, v5}, Lcom/android/server/utils/TimingsTraceAndSlog;->traceBegin(Ljava/lang/String;)V

    const-string/jumbo v5, "sys.system_server.start_count"

    iget v6, v1, Lcom/android/server/SystemServer;->mStartCount:I

    invoke-static {v6}, Ljava/lang/String;->valueOf(I)Ljava/lang/String;

    move-result-object v6

    invoke-static {v5, v6}, Landroid/os/SystemProperties;->set(Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v5, "sys.system_server.start_elapsed"

    iget-wide v6, v1, Lcom/android/server/SystemServer;->mRuntimeStartElapsedTime:J

    invoke-static {v6, v7}, Ljava/lang/String;->valueOf(J)Ljava/lang/String;

    move-result-object v6

    invoke-static {v5, v6}, Landroid/os/SystemProperties;->set(Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v5, "sys.system_server.start_uptime"

    iget-wide v6, v1, Lcom/android/server/SystemServer;->mRuntimeStartUptime:J

    invoke-static {v6, v7}, Ljava/lang/String;->valueOf(J)Ljava/lang/String;

    move-result-object v6

    invoke-static {v5, v6}, Landroid/os/SystemProperties;->set(Ljava/lang/String;Ljava/lang/String;)V

    iget v5, v1, Lcom/android/server/SystemServer;->mStartCount:I

    invoke-static {v5}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v5

    iget-wide v6, v1, Lcom/android/server/SystemServer;->mRuntimeStartUptime:J

    invoke-static {v6, v7}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v6

    iget-wide v7, v1, Lcom/android/server/SystemServer;->mRuntimeStartElapsedTime:J

    invoke-static {v7, v8}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v7

    filled-new-array {v5, v6, v7}, [Ljava/lang/Object;

    move-result-object v5

    const/16 v6, 0xbc3

    invoke-static {v6, v5}, Landroid/util/EventLog;->writeEvent(I[Ljava/lang/Object;)I

    invoke-static {}, Lcom/android/server/SystemTimeZone;->initializeTimeZoneSettingsIfRequired()V

    invoke-static {v0}, Landroid/os/SystemProperties;->get(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/String;->isEmpty()Z

    move-result v5

    if-nez v5, :cond_8d

    invoke-static {}, Ljava/util/Locale;->getDefault()Ljava/util/Locale;

    move-result-object v5

    invoke-virtual {v5}, Ljava/util/Locale;->toLanguageTag()Ljava/lang/String;

    move-result-object v5

    const-string/jumbo v6, "persist.sys.locale"

    invoke-static {v6, v5}, Landroid/os/SystemProperties;->set(Ljava/lang/String;Ljava/lang/String;)V

    invoke-static {v0, v2}, Landroid/os/SystemProperties;->set(Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v0, "persist.sys.country"

    invoke-static {v0, v2}, Landroid/os/SystemProperties;->set(Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v0, "persist.sys.localevar"

    invoke-static {v0, v2}, Landroid/os/SystemProperties;->set(Ljava/lang/String;Ljava/lang/String;)V

    :cond_8d
    const/4 v0, 0x1

    invoke-static {v0}, Landroid/os/Binder;->setWarnOnBlocking(Z)V

    invoke-static {}, Landroid/content/pm/PackageItemInfo;->forceSafeLabels()V

    const-string v2, "FULL"

    sput-object v2, Landroid/database/sqlite/SQLiteGlobal;->sDefaultSyncMode:Ljava/lang/String;

    const/4 v2, 0x0

    invoke-static {v2}, Landroid/database/sqlite/SQLiteCompatibilityWalFlags;->init(Ljava/lang/String;)V

    const-string v5, "Entered the Android system server!"

    invoke-static {v3, v5}, Landroid/util/Slog;->i(Ljava/lang/String;Ljava/lang/String;)I

    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v5

    const/16 v7, 0xbc2

    invoke-static {v7, v5, v6}, Landroid/util/EventLog;->writeEvent(IJ)I

    iget-boolean v7, v1, Lcom/android/server/SystemServer;->mRuntimeRestart:Z

    const/16 v8, 0xf0

    if-nez v7, :cond_b5

    const/16 v7, 0x13

    invoke-static {v8, v7, v5, v6}, Lcom/android/internal/util/FrameworkStatsLog;->write(IIJ)V

    :cond_b5
    invoke-static {}, Lcom/android/internal/os/ZygoteInitStub;->getInstance()Lcom/android/internal/os/ZygoteInitStub;

    move-result-object v7

    const-string/jumbo v9, "start_android"

    invoke-virtual {v7, v9}, Lcom/android/internal/os/ZygoteInitStub;->addBootEvent(Ljava/lang/String;)V

    sget-object v7, Lcom/android/server/SystemServer;->sMtkSystemServerIns:Lcom/mediatek/server/MtkSystemServer;

    const-string v9, "Android:SysServerInit_START"

    invoke-virtual {v7, v9}, Lcom/mediatek/server/MtkSystemServer;->addBootEvent(Ljava/lang/String;)V

    const-string/jumbo v7, "persist.sys.dalvik.vm.lib.2"

    invoke-static {}, Ldalvik/system/VMRuntime;->getRuntime()Ldalvik/system/VMRuntime;

    move-result-object v9

    invoke-virtual {v9}, Ldalvik/system/VMRuntime;->vmLibrary()Ljava/lang/String;

    move-result-object v9

    invoke-static {v7, v9}, Landroid/os/SystemProperties;->set(Ljava/lang/String;Ljava/lang/String;)V

    invoke-static {}, Landroid/app/ActivityThreadStub;->get()Landroid/app/ActivityThreadStub;

    move-result-object v7

    iget-object v9, v1, Lcom/android/server/SystemServer;->mSystemContext:Landroid/content/Context;

    invoke-interface {v7, v9}, Landroid/app/ActivityThreadStub;->useGrowthLimitOutExpendMethod(Landroid/content/Context;)Z

    move-result v7

    if-nez v7, :cond_e7

    invoke-static {}, Ldalvik/system/VMRuntime;->getRuntime()Ldalvik/system/VMRuntime;

    move-result-object v7

    invoke-virtual {v7}, Ldalvik/system/VMRuntime;->clearGrowthLimit()V

    :cond_e7
    invoke-static {}, Landroid/os/Build;->ensureFingerprintProperty()V

    invoke-static {v0}, Landroid/os/Environment;->setUserRequired(Z)V

    invoke-static {v0}, Landroid/os/BaseBundle;->setShouldDefuse(Z)V

    invoke-static {v0}, Landroid/os/Parcel;->setStackTraceParceling(Z)V

    invoke-static {v0}, Lcom/android/internal/os/BinderInternal;->disableBackgroundScheduling(Z)V

    const/16 v7, 0x1f

    invoke-static {v7}, Lcom/android/internal/os/BinderInternal;->setMaxThreads(I)V

    const/4 v7, -0x2

    invoke-static {v7}, Landroid/os/Process;->setThreadPriority(I)V

    const/4 v7, 0x0

    invoke-static {v7}, Landroid/os/Process;->setCanSelfBackground(Z)V

    invoke-static {}, Landroid/os/Looper;->prepareMainLooper()V

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v9

    sget-wide v10, Lcom/android/server/SystemServer;->SLOW_DISPATCH_THRESHOLD_MS:J

    sget-wide v12, Lcom/android/server/SystemServer;->SLOW_DELIVERY_THRESHOLD_MS:J

    invoke-virtual {v9, v10, v11, v12, v13}, Landroid/os/Looper;->setSlowLogThresholdMs(JJ)V

    sput-boolean v0, Landroid/app/SystemServiceRegistry;->sEnableServiceNotFoundWtf:Z

    invoke-static {}, Lcom/android/server/SystemServerInitThreadPool;->start()Lcom/android/server/SystemServerInitThreadPool;

    move-result-object v0

    move-object v9, v0

    iget-object v0, v1, Lcom/android/server/SystemServer;->mDumper:Lcom/android/server/SystemServer$SystemServerDumper;

    invoke-static {v0, v9}, Lcom/android/server/SystemServer$SystemServerDumper;->-$$Nest$maddDumpable(Lcom/android/server/SystemServer$SystemServerDumper;Landroid/util/Dumpable;)V

    invoke-static {}, Landroid/server/Flags;->earlySystemConfigInit()Z

    move-result v0

    if-eqz v0, :cond_126

    invoke-direct {v1, v4}, Lcom/android/server/SystemServer;->startSystemConfigInit(Lcom/android/server/utils/TimingsTraceAndSlog;)V

    :cond_126
    const-string v0, "android_servers"

    invoke-static {v0}, Ljava/lang/System;->loadLibrary(Ljava/lang/String;)V

    invoke-static {}, Lcom/android/server/SystemServer;->initZygoteChildHeapProfiling()V

    sget-boolean v0, Landroid/os/Build;->IS_DEBUGGABLE:Z

    invoke-direct {v1}, Lcom/android/server/SystemServer;->performPendingShutdown()V

    invoke-direct {v1}, Lcom/android/server/SystemServer;->createSystemContext()V

    invoke-static {}, Landroid/app/ActivityThread;->initializeMainlineModules()V

    const-string/jumbo v0, "system_server_dumper"

    iget-object v10, v1, Lcom/android/server/SystemServer;->mDumper:Lcom/android/server/SystemServer$SystemServerDumper;

    invoke-static {v0, v10}, Landroid/os/ServiceManager;->addService(Ljava/lang/String;Landroid/os/IBinder;)V

    iget-object v0, v1, Lcom/android/server/SystemServer;->mDumper:Lcom/android/server/SystemServer$SystemServerDumper;

    invoke-static {v0, v1}, Lcom/android/server/SystemServer$SystemServerDumper;->-$$Nest$maddDumpable(Lcom/android/server/SystemServer$SystemServerDumper;Landroid/util/Dumpable;)V

    new-instance v0, Lcom/android/server/SystemServiceManager;

    iget-object v10, v1, Lcom/android/server/SystemServer;->mSystemContext:Landroid/content/Context;

    invoke-direct {v0, v10}, Lcom/android/server/SystemServiceManager;-><init>(Landroid/content/Context;)V

    iput-object v0, v1, Lcom/android/server/SystemServer;->mSystemServiceManager:Lcom/android/server/SystemServiceManager;

    iget-object v11, v1, Lcom/android/server/SystemServer;->mSystemServiceManager:Lcom/android/server/SystemServiceManager;

    iget-boolean v12, v1, Lcom/android/server/SystemServer;->mRuntimeRestart:Z

    iget-wide v13, v1, Lcom/android/server/SystemServer;->mRuntimeStartElapsedTime:J

    move-object/from16 v17, v9

    iget-wide v8, v1, Lcom/android/server/SystemServer;->mRuntimeStartUptime:J

    move-wide v15, v8

    invoke-virtual/range {v11 .. v16}, Lcom/android/server/SystemServiceManager;->setStartInfo(ZJJ)V

    iget-object v0, v1, Lcom/android/server/SystemServer;->mDumper:Lcom/android/server/SystemServer$SystemServerDumper;

    iget-object v8, v1, Lcom/android/server/SystemServer;->mSystemServiceManager:Lcom/android/server/SystemServiceManager;

    invoke-static {v0, v8}, Lcom/android/server/SystemServer$SystemServerDumper;->-$$Nest$maddDumpable(Lcom/android/server/SystemServer$SystemServerDumper;Landroid/util/Dumpable;)V

    const-class v0, Lcom/android/server/SystemServiceManager;

    iget-object v8, v1, Lcom/android/server/SystemServer;->mSystemServiceManager:Lcom/android/server/SystemServiceManager;

    invoke-static {v0, v8}, Lcom/android/server/LocalServices;->addService(Ljava/lang/Class;Ljava/lang/Object;)V

    invoke-static {}, Lcom/android/text/flags/Flags;->useOptimizedBoottimeFontLoading()Z

    move-result v0

    if-nez v0, :cond_18a

    const-string v0, "Loading pre-installed system font map."

    invoke-static {v3, v0}, Landroid/util/Slog;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_176
    .catchall {:try_start_e .. :try_end_176} :catchall_2d7

    :try_start_176
    invoke-static {}, Landroid/graphics/Typeface;->loadPreinstalledSystemFontMap()V
    :try_end_179
    .catch Ljava/lang/Exception; {:try_start_176 .. :try_end_179} :catch_17a
    .catchall {:try_start_176 .. :try_end_179} :catchall_2d7

    goto :goto_18a

    :catch_17a
    move-exception v0

    :try_start_17b
    const-string v8, "System font map reload"

    invoke-static {v3, v8}, Landroid/util/Slog;->i(Ljava/lang/String;Ljava/lang/String;)I

    invoke-static {}, Lcom/android/server/SystemServerStub;->get()Lcom/android/server/SystemServerStub;

    move-result-object v3

    invoke-virtual {v3}, Lcom/android/server/SystemServerStub;->resetFonts()V

    invoke-static {}, Landroid/graphics/Typeface;->loadPreinstalledSystemFontMap()V

    :cond_18a
    :goto_18a
    sget-boolean v0, Landroid/os/Build;->IS_DEBUGGABLE:Z
    :try_end_18c
    .catchall {:try_start_17b .. :try_end_18c} :catchall_2d7

    const-string v3, "System"

    if-eqz v0, :cond_1d5

    :try_start_190
    const-string/jumbo v0, "persist.sys.dalvik.jvmtiagent"

    invoke-static {v0}, Landroid/os/SystemProperties;->get(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    move-object v8, v0

    invoke-virtual {v8}, Ljava/lang/String;->isEmpty()Z

    move-result v0

    if-nez v0, :cond_1d5

    const/16 v0, 0x3d

    invoke-virtual {v8, v0}, Ljava/lang/String;->indexOf(I)I

    move-result v0

    move v9, v0

    invoke-virtual {v8, v7, v9}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v0

    move-object v11, v0

    add-int/lit8 v0, v9, 0x1

    invoke-virtual {v8}, Ljava/lang/String;->length()I

    move-result v12

    invoke-virtual {v8, v0, v12}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v0
    :try_end_1b4
    .catchall {:try_start_190 .. :try_end_1b4} :catchall_2d7

    move-object v12, v0

    :try_start_1b5
    invoke-static {v11, v12, v2}, Landroid/os/Debug;->attachJvmtiAgent(Ljava/lang/String;Ljava/lang/String;Ljava/lang/ClassLoader;)V
    :try_end_1b8
    .catch Ljava/lang/Exception; {:try_start_1b5 .. :try_end_1b8} :catch_1b9
    .catchall {:try_start_1b5 .. :try_end_1b8} :catchall_2d7

    goto :goto_1d5

    :catch_1b9
    move-exception v0

    :try_start_1ba
    const-string v13, "*************************************************"

    invoke-static {v3, v13}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    new-instance v13, Ljava/lang/StringBuilder;

    invoke-direct {v13}, Ljava/lang/StringBuilder;-><init>()V

    const-string v14, "********** Failed to load jvmti plugin: "

    invoke-virtual {v13, v14}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v13

    invoke-virtual {v13, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v13

    invoke-virtual {v13}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v13

    invoke-static {v3, v13}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_1d5
    .catchall {:try_start_1ba .. :try_end_1d5} :catchall_2d7

    :cond_1d5
    :goto_1d5
    invoke-virtual {v4}, Lcom/android/server/utils/TimingsTraceAndSlog;->traceEnd()V

    nop

    sget-object v0, Lcom/android/server/SystemServer;->sMtkSystemServerIns:Lcom/mediatek/server/MtkSystemServer;

    sget-object v5, Lcom/android/server/SystemServer;->BOOT_TIMINGS_TRACE_LOG:Lcom/android/server/utils/TimingsTraceAndSlog;

    iget-object v6, v1, Lcom/android/server/SystemServer;->mSystemServiceManager:Lcom/android/server/SystemServiceManager;

    iget-object v8, v1, Lcom/android/server/SystemServer;->mSystemContext:Landroid/content/Context;

    invoke-virtual {v0, v5, v6, v8}, Lcom/mediatek/server/MtkSystemServer;->setPrameters(Lcom/android/server/utils/TimingsTraceAndSlog;Lcom/android/server/SystemServiceManager;Landroid/content/Context;)V

    new-instance v0, Lcom/android/server/SystemServer$$ExternalSyntheticLambda3;

    invoke-direct {v0}, Lcom/android/server/SystemServer$$ExternalSyntheticLambda3;-><init>()V

    invoke-static {v0}, Lcom/android/internal/os/RuntimeInit;->setDefaultApplicationWtfHandler(Lcom/android/internal/os/RuntimeInit$ApplicationWtfHandler;)V

    const-string v0, "debug.debug_system"

    invoke-static {v0, v7}, Landroid/os/SystemProperties;->getBoolean(Ljava/lang/String;Z)Z

    move-result v0

    if-eqz v0, :cond_1f7

    invoke-static {}, Landroid/os/Debug;->waitForDebugger()V

    :cond_1f7
    invoke-static {}, Lcom/android/internal/os/ApplicationSharedMemory;->create()Lcom/android/internal/os/ApplicationSharedMemory;

    move-result-object v5

    invoke-static {v5}, Lcom/android/internal/os/ApplicationSharedMemory;->setInstance(Lcom/android/internal/os/ApplicationSharedMemory;)V

    :try_start_1fe
    const-string v0, "StartServices"

    invoke-virtual {v4, v0}, Lcom/android/server/utils/TimingsTraceAndSlog;->traceBegin(Ljava/lang/String;)V

    invoke-direct {v1, v4}, Lcom/android/server/SystemServer;->startBootstrapServices(Lcom/android/server/utils/TimingsTraceAndSlog;)V

    sget-object v0, Lcom/android/server/SystemServer;->sMtkSystemServerIns:Lcom/mediatek/server/MtkSystemServer;

    invoke-virtual {v0}, Lcom/mediatek/server/MtkSystemServer;->startMtkBootstrapServices()V

    invoke-direct {v1, v4}, Lcom/android/server/SystemServer;->startCoreServices(Lcom/android/server/utils/TimingsTraceAndSlog;)V

    sget-object v0, Lcom/android/server/SystemServer;->sMtkSystemServerIns:Lcom/mediatek/server/MtkSystemServer;

    invoke-virtual {v0}, Lcom/mediatek/server/MtkSystemServer;->startMtkCoreServices()V

    #Start Kaorios
    invoke-static {}, Landroid/security/kaorios/KaoriosHook;->initSystemServer()V
    #End Kaorios

    invoke-direct {v1, v4}, Lcom/android/server/SystemServer;->startOtherServices(Lcom/android/server/utils/TimingsTraceAndSlog;)V

    invoke-direct {v1, v4}, Lcom/android/server/SystemServer;->startApexServices(Lcom/android/server/utils/TimingsTraceAndSlog;)V

    invoke-direct {v1, v4}, Lcom/android/server/SystemServer;->updateWatchdogTimeout(Lcom/android/server/utils/TimingsTraceAndSlog;)V

    invoke-static {}, Lcom/android/internal/os/ZygoteConfigStub;->getInstance()Lcom/android/internal/os/ZygoteConfigStub;

    move-result-object v0

    iget-object v6, v1, Lcom/android/server/SystemServer;->mSystemContext:Landroid/content/Context;

    invoke-virtual {v0, v6}, Lcom/android/internal/os/ZygoteConfigStub;->initialize(Landroid/content/Context;)V

    invoke-static {}, Lcom/android/server/criticalevents/CriticalEventLog;->getInstance()Lcom/android/server/criticalevents/CriticalEventLog;

    move-result-object v0

    invoke-virtual {v0}, Lcom/android/server/criticalevents/CriticalEventLog;->logSystemServerStarted()V
    :try_end_22f
    .catchall {:try_start_1fe .. :try_end_22f} :catchall_2c5

    invoke-virtual {v4}, Lcom/android/server/utils/TimingsTraceAndSlog;->traceEnd()V

    nop

    invoke-static {v2}, Landroid/os/StrictMode;->initVmDefaults(Landroid/content/pm/ApplicationInfo;)V

    iget-boolean v0, v1, Lcom/android/server/SystemServer;->mRuntimeRestart:Z

    if-nez v0, :cond_26d

    invoke-direct {v1}, Lcom/android/server/SystemServer;->isFirstBootOrUpgrade()Z

    move-result v0

    if-nez v0, :cond_26d

    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v2

    const/16 v0, 0x14

    const/16 v10, 0xf0

    invoke-static {v10, v0, v2, v3}, Lcom/android/internal/util/FrameworkStatsLog;->write(IIJ)V

    const-wide/32 v6, 0xea60

    const-wide/32 v8, 0xea60

    cmp-long v0, v2, v8

    if-lez v0, :cond_26d

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v8, "SystemServer init took too long. uptimeMillis="

    invoke-virtual {v0, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v2, v3}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    const-string v8, "SystemServerTiming"

    invoke-static {v8, v0}, Landroid/util/Slog;->wtf(Ljava/lang/String;Ljava/lang/String;)I

    :cond_26d
    new-instance v0, Lcom/android/server/SystemServer$1;

    invoke-direct {v0, v1}, Lcom/android/server/SystemServer$1;-><init>(Lcom/android/server/SystemServer;)V

    invoke-static {v0}, Landroid/os/Binder;->setTransactionCallback(Landroid/os/IBinderCallback;)V

    invoke-static {}, Lcom/android/server/BootKeeperStub;->getInstance()Lcom/android/server/BootKeeperStub;

    move-result-object v0

    iget-object v2, v1, Lcom/android/server/SystemServer;->mSystemContext:Landroid/content/Context;

    invoke-interface {v0, v2}, Lcom/android/server/BootKeeperStub;->afterBoot(Landroid/content/Context;)V

    invoke-static {}, Lcom/android/server/apppreload/MiuiAppLaunchPreloadStub;->getInstance()Lcom/android/server/apppreload/MiuiAppLaunchPreloadStub;

    move-result-object v0

    iget-object v2, v1, Lcom/android/server/SystemServer;->mSystemContext:Landroid/content/Context;

    invoke-interface {v0, v2}, Lcom/android/server/apppreload/MiuiAppLaunchPreloadStub;->initialize(Landroid/content/Context;)V

    invoke-static {}, Landroid/app/Flags;->reportPostgcMemoryMetrics()Z

    move-result v0

    if-eqz v0, :cond_29b

    invoke-static {}, Lcom/android/libcore/readonly/Flags;->postCleanupApis()Z

    move-result v0

    if-eqz v0, :cond_29b

    new-instance v0, Lcom/android/server/SystemServer$2;

    invoke-direct {v0, v1}, Lcom/android/server/SystemServer$2;-><init>(Lcom/android/server/SystemServer;)V

    invoke-static {v0}, Ldalvik/system/VMRuntime;->addPostCleanupCallback(Ljava/lang/Runnable;)V

    :cond_29b
    sget-object v0, Lcom/android/server/SystemServer;->sMtkSystemServerIns:Lcom/mediatek/server/MtkSystemServer;

    const-string v2, "Android:SysServerInit_END"

    invoke-virtual {v0, v2}, Lcom/mediatek/server/MtkSystemServer;->addBootEvent(Ljava/lang/String;)V

    const-string/jumbo v0, "ro.boot.hwlevel"

    invoke-static {v0}, Landroid/os/SystemProperties;->get(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    const-string v2, "MP"

    invoke-virtual {v2, v0}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_2ba

    invoke-static {}, Lcom/android/server/SystemServerStub;->get()Lcom/android/server/SystemServerStub;

    move-result-object v0

    iget-object v2, v1, Lcom/android/server/SystemServer;->mContentResolver:Landroid/content/ContentResolver;

    invoke-virtual {v0, v2}, Lcom/android/server/SystemServerStub;->registerThreadPoolTraceObserver(Landroid/content/ContentResolver;)V

    :cond_2ba
    invoke-static {}, Landroid/os/Looper;->loop()V

    new-instance v0, Ljava/lang/RuntimeException;

    const-string v2, "Main thread loop unexpectedly exited"

    invoke-direct {v0, v2}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v0

    :catchall_2c5
    move-exception v0

    :try_start_2c6
    const-string v2, "******************************************"

    invoke-static {v3, v2}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    const-string v2, "************ Failure starting system services"

    invoke-static {v3, v2, v0}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    nop

    throw v0
    :try_end_2d2
    .catchall {:try_start_2c6 .. :try_end_2d2} :catchall_2d2

    :catchall_2d2
    move-exception v0

    invoke-virtual {v4}, Lcom/android/server/utils/TimingsTraceAndSlog;->traceEnd()V

    throw v0

    :catchall_2d7
    move-exception v0

    invoke-virtual {v4}, Lcom/android/server/utils/TimingsTraceAndSlog;->traceEnd()V

    throw v0
.end method
