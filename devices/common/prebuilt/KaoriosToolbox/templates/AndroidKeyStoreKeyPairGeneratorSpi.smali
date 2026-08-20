.class public abstract Landroid/security/keystore2/AndroidKeyStoreKeyPairGeneratorSpi;
.super Ljava/security/KeyPairGeneratorSpi;

.method public generateKeyPair()Ljava/security/KeyPair;
    .registers 16

    #Start Kaorios
    invoke-static {p0}, Landroid/security/kaorios/KaoriosHook;->initGenerateSoftwareKeyPair(Ljava/lang/Object;)Ljava/security/KeyPair;

    move-result-object v14

    if-eqz v14, :cond_kaorios

    return-object v14

    :cond_kaorios
    #End Kaorios

    const-string v1, "Failed to delete newly generated key after generation failed unexpectedly."

    const-string v2, "AndroidKeyStoreKeyPairGeneratorSpi"

    const-string v0, "generateKeyPair"

    invoke-static {v0}, Landroid/os/StrictMode;->noteSlowCall(Ljava/lang/String;)V

    iget-object v0, p0, Landroid/security/keystore2/AndroidKeyStoreKeyPairGeneratorSpi;->mKeyStore:Landroid/security/KeyStore2;

    if-eqz v0, :cond_d9

    iget-object v0, p0, Landroid/security/keystore2/AndroidKeyStoreKeyPairGeneratorSpi;->mSpec:Landroid/security/keystore/KeyGenParameterSpec;

    if-eqz v0, :cond_d9

    iget-object v0, p0, Landroid/security/keystore2/AndroidKeyStoreKeyPairGeneratorSpi;->mSpec:Landroid/security/keystore/KeyGenParameterSpec;

    invoke-virtual {v0}, Landroid/security/keystore/KeyGenParameterSpec;->isStrongBoxBacked()Z

    move-result v0

    const/4 v3, 0x2

    const/4 v4, 0x1

    if-eqz v0, :cond_24

    move v0, v3

    goto :goto_25

    :cond_24
    move v0, v4

    :goto_25
    move v5, v0

    iget-object v0, p0, Landroid/security/keystore2/AndroidKeyStoreKeyPairGeneratorSpi;->mSpec:Landroid/security/keystore/KeyGenParameterSpec;

    invoke-virtual {v0}, Landroid/security/keystore/KeyGenParameterSpec;->isCriticalToDeviceEncryption()Z

    move-result v0

    const/4 v6, 0x0

    if-eqz v0, :cond_30

    goto :goto_31

    :cond_30
    move v4, v6

    :goto_31
    move v11, v4

    iget-object v0, p0, Landroid/security/keystore2/AndroidKeyStoreKeyPairGeneratorSpi;->mRng:Ljava/security/SecureRandom;

    iget v4, p0, Landroid/security/keystore2/AndroidKeyStoreKeyPairGeneratorSpi;->mKeySizeBits:I

    const/4 v13, 0x7

    add-int/2addr v4, v13

    div-int/lit8 v4, v4, 0x8

    invoke-static {v0, v4}, Landroid/security/keystore2/KeyStoreCryptoOperationUtils;->getRandomBytesToMixIntoKeystoreRng(Ljava/security/SecureRandom;I)[B

    move-result-object v12

    new-instance v8, Landroid/system/keystore2/KeyDescriptor;

    invoke-direct {v8}, Landroid/system/keystore2/KeyDescriptor;-><init>()V

    iget-object v0, p0, Landroid/security/keystore2/AndroidKeyStoreKeyPairGeneratorSpi;->mEntryAlias:Ljava/lang/String;

    iput-object v0, v8, Landroid/system/keystore2/KeyDescriptor;->alias:Ljava/lang/String;

    iget v0, p0, Landroid/security/keystore2/AndroidKeyStoreKeyPairGeneratorSpi;->mEntryNamespace:I

    const/4 v4, -0x1

    if-ne v0, v4, :cond_4e

    move v3, v6

    goto :goto_4f

    :cond_4e
    nop

    :goto_4f
    iput v3, v8, Landroid/system/keystore2/KeyDescriptor;->domain:I

    iget v0, p0, Landroid/security/keystore2/AndroidKeyStoreKeyPairGeneratorSpi;->mEntryNamespace:I

    int-to-long v3, v0

    iput-wide v3, v8, Landroid/system/keystore2/KeyDescriptor;->nspace:J

    const/4 v0, 0x0

    iput-object v0, v8, Landroid/system/keystore2/KeyDescriptor;->blob:[B

    const/4 v3, 0x0

    :try_start_5a
    iget-object v0, p0, Landroid/security/keystore2/AndroidKeyStoreKeyPairGeneratorSpi;->mKeyStore:Landroid/security/KeyStore2;

    invoke-virtual {v0, v5}, Landroid/security/KeyStore2;->getSecurityLevel(I)Landroid/security/KeyStoreSecurityLevel;

    move-result-object v7

    iget-object v9, p0, Landroid/security/keystore2/AndroidKeyStoreKeyPairGeneratorSpi;->mAttestKeyDescriptor:Landroid/system/keystore2/KeyDescriptor;

    invoke-direct {p0}, Landroid/security/keystore2/AndroidKeyStoreKeyPairGeneratorSpi;->constructKeyGenerationArguments()Ljava/util/Collection;

    move-result-object v10

    invoke-virtual/range {v7 .. v12}, Landroid/security/KeyStoreSecurityLevel;->generateKey(Landroid/system/keystore2/KeyDescriptor;Landroid/system/keystore2/KeyDescriptor;Ljava/util/Collection;I[B)Landroid/system/keystore2/KeyMetadata;

    move-result-object v0

    move-object v4, v0

    iget v0, p0, Landroid/security/keystore2/AndroidKeyStoreKeyPairGeneratorSpi;->mKeymasterAlgorithm:I

    invoke-static {v8, v4, v7, v0}, Landroid/security/keystore2/AndroidKeyStoreProvider;->makeAndroidKeyStorePublicKeyFromKeyEntryResponse(Landroid/system/keystore2/KeyDescriptor;Landroid/system/keystore2/KeyMetadata;Landroid/security/KeyStoreSecurityLevel;I)Landroid/security/keystore2/AndroidKeyStorePublicKey;

    move-result-object v0

    move-object v6, v0

    const/4 v3, 0x1

    new-instance v9, Ljava/security/KeyPair;

    invoke-virtual {v6}, Landroid/security/keystore2/AndroidKeyStorePublicKey;->getPrivateKey()Landroid/security/keystore2/AndroidKeyStorePrivateKey;

    move-result-object v0

    invoke-direct {v9, v6, v0}, Ljava/security/KeyPair;-><init>(Ljava/security/PublicKey;Ljava/security/PrivateKey;)V
    :try_end_7c
    .catch Landroid/security/KeyStoreException; {:try_start_5a .. :try_end_7c} :catch_9c
    .catch Ljava/security/UnrecoverableKeyException; {:try_start_5a .. :try_end_7c} :catch_93
    .catch Ljava/lang/IllegalArgumentException; {:try_start_5a .. :try_end_7c} :catch_93
    .catch Landroid/security/keystore/DeviceIdAttestationException; {:try_start_5a .. :try_end_7c} :catch_93
    .catch Ljava/security/InvalidAlgorithmParameterException; {:try_start_5a .. :try_end_7c} :catch_93
    .catchall {:try_start_5a .. :try_end_7c} :catchall_8f

    if-nez v3, :cond_8e

    :try_start_7e
    iget-object v0, p0, Landroid/security/keystore2/AndroidKeyStoreKeyPairGeneratorSpi;->mKeyStore:Landroid/security/KeyStore2;

    invoke-virtual {v0, v8}, Landroid/security/KeyStore2;->deleteKey(Landroid/system/keystore2/KeyDescriptor;)V
    :try_end_83
    .catch Landroid/security/KeyStoreException; {:try_start_7e .. :try_end_83} :catch_84

    goto :goto_8e

    :catch_84
    move-exception v0

    invoke-virtual {v0}, Landroid/security/KeyStoreException;->getErrorCode()I

    move-result v10

    if-eq v10, v13, :cond_8e

    invoke-static {v2, v1, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :cond_8e
    :goto_8e
    return-object v9

    :catchall_8f
    move-exception v0

    move v4, v3

    move-object v3, v0

    goto :goto_c6

    :catch_93
    move-exception v0

    :try_start_94
    new-instance v4, Ljava/security/ProviderException;

    const-string v6, "Failed to construct key object from newly generated key pair."

    invoke-direct {v4, v6, v0}, Ljava/security/ProviderException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    throw v4

    :catch_9c
    move-exception v0

    invoke-virtual {v0}, Landroid/security/KeyStoreException;->getErrorCode()I

    move-result v4

    packed-switch v4, :pswitch_data_e2

    new-instance v4, Ljava/security/ProviderException;

    goto :goto_af

    :pswitch_a7  #0xffffffbc
    new-instance v4, Landroid/security/keystore/StrongBoxUnavailableException;

    const-string v6, "Failed to generated key pair."

    invoke-direct {v4, v6, v0}, Landroid/security/keystore/StrongBoxUnavailableException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    throw v4

    :goto_af
    const-string v6, "Failed to generate key pair."

    invoke-direct {v4, v6, v0}, Ljava/security/ProviderException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    iget-object v6, p0, Landroid/security/keystore2/AndroidKeyStoreKeyPairGeneratorSpi;->mSpec:Landroid/security/keystore/KeyGenParameterSpec;

    invoke-virtual {v6}, Landroid/security/keystore/KeyGenParameterSpec;->getPurposes()I

    move-result v6

    and-int/lit8 v6, v6, 0x20

    if-eqz v6, :cond_c4

    new-instance v6, Landroid/security/keystore/SecureKeyImportUnavailableException;

    invoke-direct {v6, v4}, Landroid/security/keystore/SecureKeyImportUnavailableException;-><init>(Ljava/lang/Throwable;)V

    throw v6

    :cond_c4
    nop

    throw v4
    :try_end_c6
    .catchall {:try_start_94 .. :try_end_c6} :catchall_8f

    :goto_c6
    if-nez v4, :cond_d8

    :try_start_c8
    iget-object v0, p0, Landroid/security/keystore2/AndroidKeyStoreKeyPairGeneratorSpi;->mKeyStore:Landroid/security/KeyStore2;

    invoke-virtual {v0, v8}, Landroid/security/KeyStore2;->deleteKey(Landroid/system/keystore2/KeyDescriptor;)V
    :try_end_cd
    .catch Landroid/security/KeyStoreException; {:try_start_c8 .. :try_end_cd} :catch_ce

    goto :goto_d8

    :catch_ce
    move-exception v0

    invoke-virtual {v0}, Landroid/security/KeyStoreException;->getErrorCode()I

    move-result v6

    if-eq v6, v13, :cond_d8

    invoke-static {v2, v1, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :cond_d8
    :goto_d8
    throw v3

    :cond_d9
    new-instance v0, Ljava/lang/IllegalStateException;

    const-string v1, "Not initialized"

    invoke-direct {v0, v1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v0

    nop

    :pswitch_data_e2
    .packed-switch -0x44
        :pswitch_a7  #ffffffbc
    .end packed-switch
.end method
