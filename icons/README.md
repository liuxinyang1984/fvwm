# icons

| 文件 | 说明 |
|------|------|
| `default.png` | 全局最小化默认图标（48×48，FVWM 会按 `IconSize 90 70` 摆） |

`default.png`：Motif/CDE 风终端窗，本仓绘制，可自由使用。

规则在 `conf.d/45-icons.conf`，**数值与 Class 列表对齐** [fvwm2-sgi](https://github.com/ZoomTen/fvwm2-sgi) 的 `icons.fvwm2rc`（含 `IconBox 1680x305+135+6`、`IconSize 90 70`、Helvetica `IconFont`）。  
所有 `Icon` / `IconOverride` 指向本仓 `default.png`，不引入其截图 PNG。小屏可在 `local.conf` 里改 `IconBox`。
