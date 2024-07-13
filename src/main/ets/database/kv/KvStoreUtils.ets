import { distributedKVStore } from '@kit.ArkData';


/**
 * 创建一个 KVManager 实例
 * @param context
 * @param bundleName 包名
 * */
export function createKvManager(context: Context, bundleName: string): distributedKVStore.KVManager {
    return distributedKVStore.createKVManager({
        bundleName,
        context
    });
}

/**
 * KvStore 所需参数
 * */
export interface KVStoreOptions {
    createIfMissing?: boolean,
    encrypt?: boolean,
    backup?: boolean,
    autoSync?: boolean
}

/**
 * 创建并获取 [SingleKVStore] 的实例
 * @param kvManager
 * @param storeId
 * @param createIfMissing
 * @param encrypt
 * @param backup
 * @param autoSync
 * @param securityLevel
 * */
export function getSingleKVStore(
    kvManager: distributedKVStore.KVManager,
    storeId: string,
    securityLevel: distributedKVStore.SecurityLevel,
    options?: KVStoreOptions
): Promise<distributedKVStore.SingleKVStore> {
    return kvManager.getKVStore(storeId, {
        createIfMissing: options?.createIfMissing,
        encrypt: options?.encrypt,
        backup: options?.backup,
        autoSync: options?.autoSync,
        kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
        securityLevel
    })
}

/**
 * 创建并获取 DeviceKVStore 的实例
 * @param kvManager
 * @param storeId 数据库id
 * @param createIfMissing 不存在则创建数据库文件，默认为true
 * @param encrypt 加密文件
 * @param backup 备份文件
 * @param autoSync 自动同步
 * @param securityLevel 安全等级
 * */
export function getDeviceKVStore(
    kvManager: distributedKVStore.KVManager,
    storeId: string,
    securityLevel: distributedKVStore.SecurityLevel,
    options?: KVStoreOptions
): Promise<distributedKVStore.DeviceKVStore> {
    return kvManager.getKVStore(storeId, {
        createIfMissing: options?.createIfMissing,
        encrypt: options?.encrypt,
        backup: options?.backup,
        autoSync: options?.autoSync,
        kvStoreType: distributedKVStore.KVStoreType.DEVICE_COLLABORATION,
        securityLevel
    })
}

/**
 * 返回一个 boolean 类型的 Entry
 * */
export function booleanEntry(
    key: string,
    value: boolean
): distributedKVStore.Entry {
    return {
        key,
        value: {
            type: distributedKVStore.ValueType.BOOLEAN,
            value
        }
    }
}


/**
 * 返回一个 string 类型的 Entry
 * */
export function strEntry(
    key: string,
    value: string
): distributedKVStore.Entry {
    return {
        key,
        value: {
            type: distributedKVStore.ValueType.STRING,
            value
        }
    }
}


/**
 * 返回一个 int 类型的 Entry
 * */
export function intEntry(
    key: string,
    value: number
): distributedKVStore.Entry {
    return {
        key,
        value: {
            type: distributedKVStore.ValueType.INTEGER,
            value
        }
    }
}


/**
 * 返回一个 float 类型的 Entry
 * */
export function floatEntry(
    key: string,
    value: number
): distributedKVStore.Entry {
    return {
        key,
        value: {
            type: distributedKVStore.ValueType.FLOAT,
            value
        }
    }
}


/**
 * 返回一个 double 类型的 Entry
 * */
export function doubleEntry(
    key: string,
    value: number
): distributedKVStore.Entry {
    return {
        key,
        value: {
            type: distributedKVStore.ValueType.DOUBLE,
            value
        }
    }
}


export enum ChangeType {
    INSERT,
    UPDATE,
    DELETE,
}

/**
 * 监听指定 key 的变化
 * */
export function watch(
    kvStore: distributedKVStore.SingleKVStore | distributedKVStore.DeviceKVStore,
    key: string,
    subscribeType: distributedKVStore.SubscribeType,
    callback: (type: ChangeType, value: distributedKVStore.Value) => void
) {
    kvStore.on('dataChange', subscribeType, (data) => {
        data.insertEntries.forEach((item) => {
            if (item.key === key) {
                callback(ChangeType.INSERT, item.value)
            }
        })
        data.updateEntries.forEach((item) => {
            if (item.key === key) {
                callback(ChangeType.UPDATE, item.value)
            }
        })
        data.deleteEntries.forEach((item) => {
            if (item.key === key) {
                callback(ChangeType.DELETE, item.value)
            }
        })
    })
}