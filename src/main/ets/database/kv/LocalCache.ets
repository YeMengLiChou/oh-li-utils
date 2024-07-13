import distributedKVStore from '@ohos.data.distributedKVStore'

/**
 * 本地缓存类
 * */
export class LocalCacheModel<T> {
    /** 存储数据 */
    private data: T
    /** 过期时间 */
    private invalidateTime: number

    constructor(data: T, invalidate: number) {
        this.data = data
        this.invalidateTime = invalidate
    }

    checkInvalidate() {
        return Date.now() >= this.invalidateTime
    }

    getData() {
        if (this.checkInvalidate()) {
            return undefined
        } else {
            return this.data
        }
    }
}


/**
 * 获取缓存数据
 * */
export async function getLocalCache<T>(store: distributedKVStore.SingleKVStore, key: string): Promise<Optional<T>> {
    try {
        const data = JSON.parse(await store.get(key) as string) as LocalCacheModel<T>
        if (data.checkInvalidate()) {
            store.delete(key)
        } else {
            return data.getData()
        }
    } catch (error) {
        return undefined
    }
    return undefined

}

/**
 * 设置本地缓存，并指定过期时间 invalidateTime
 *
 * @param store
 * @param key
 * @param value
 * @param invalidateTime 过期时间（时间戳）
 *
 * */
export async function setLocalCache<T>(store: distributedKVStore.SingleKVStore, key: string,
    value: T, invalidateTime: number) {
    const data = new LocalCacheModel(value, invalidateTime)
    await store.put(key, JSON.stringify(data))
}

/**
 * 设置本地缓存，并指定超时时间（timeout毫秒后缓存失效）
 * @param store
 * @param key
 * @param value
 * @param invalidateTime 过期时间（时间戳）
 * */
export async function setLocalCacheTimeout<T>(store: distributedKVStore.SingleKVStore, key: string,
    value: T, timeout: number) {
    const data = new LocalCacheModel(value, Date.now() + timeout)
    await store.put(key, JSON.stringify(data))
}

export async function getAndSetLocalCache<T>(
    store: distributedKVStore.SingleKVStore,
    key: string,
    value: T,
    invalidateTime: number
) {
    const pre = await getLocalCache<T>(store, key)
    await setLocalCache(store, key, value, invalidateTime)
    return pre
}