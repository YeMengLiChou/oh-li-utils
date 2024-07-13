import { geoLocationManager } from '@kit.LocationKit'
import { BusinessError } from '@kit.BasicServicesKit';
import { requirePermissionsPromise } from '../common/PermissionUtils';
import common from '@ohos.app.ability.common';


/**
 * 获取系统缓存最新的位置信息
 * @permission ohos.permission.APPROXIMATELY_LOCATION
 * @param {number} validateTime 缓存信息有效时间，单位毫秒，不设置则不进行检查
 * */
export async function requestLocation(
    validateTime?: number
): Promise<Optional<geoLocationManager.Location>> {
    let location: Optional<geoLocationManager.Location> = undefined
    try {
        location = geoLocationManager.getLastLocation()
        // 如果大于5min，则使用实时的定位信息
        if (validateTime && new Date().getTime() - location.timeStamp >= validateTime) {
            return await requestCurrentLocation()
        }
        return location
    } catch (error) {
        // 系统不存在缓存信息时使用当前定位信息
        const e = error as BusinessError
        console.error(`requestLocation failed and try to use accuracy location! ${e.code} ${e.message}! `)
        return await requestCurrentLocation()
    }
}

/**
 * 获取当前定位信息，非缓存信息
 * @permission ohos.permission.APPROXIMATELY_LOCATION
 * */
export async function requestCurrentLocation(): Promise<Optional<geoLocationManager.Location>> {
    let request: geoLocationManager.SingleLocationRequest = {
        locatingPriority: geoLocationManager.LocatingPriority.PRIORITY_LOCATING_SPEED,
        locatingTimeoutMs: 5000
    }
    try {
        return await geoLocationManager.getCurrentLocation(request)
    } catch (error) {
        const e = error as BusinessError
        console.error(`requestAccuracyLocaion failed! ${e.code} ${e.message}`)
    }
    return undefined
}

/**
 * 请求定位相关的权限，返回 Promise，权限未授予时触发catch
 * */
export function requestLocationPermissions(context: common.UIAbilityContext): Promise<void> {
    return requirePermissionsPromise(
        ["ohos.permission.LOCATION", "ohos.permission.APPROXIMATELY_LOCATION"],
        context
    )
}

