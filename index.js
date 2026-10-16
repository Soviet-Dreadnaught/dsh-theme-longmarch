/**
 * 长征终端 —— 宿主半侧。
 *
 * 纯视觉插件：主题令牌、背景层、扫描线、设置页全部在浏览器半侧
 * （package.json 的 dsh.client 声明把 ./client 交给客户端模块系统）。
 * 这里保留空的 apply，是为了让包在宿主 Loader 里正常挂行，
 * 并让 client-modules 的扫描把它识别为 web 客户端插件。
 */
export function apply() {}
