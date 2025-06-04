Conch线上使用的补丁：
 * patch_dat: 二进制，大幅提升线补丁初始化速度，使用ConchDispatch.loadByteSource加载的补丁
 * patch_zip: 依赖conch_loader，打包资源与路由信息，可被loader直接使用的补丁
 
 本次编译的基准文件：
 * conch_base_xxx.json: 包含基准包信息，请保存并在下次编译补丁时放入工程根目录/conch_base/下
 
 其他产物：
 * patch_json: 可读的补丁，用于调试
 * assets: 补丁调用到的本地资源，请检查确认。也可使用assets/.total确保资源热更完全
 * page_config: conch_loader使用的路由信息
 
 若基准包开启混淆：
  * ！请使用obfuscate目录下产物
