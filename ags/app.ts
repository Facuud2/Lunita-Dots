import app from "ags/gtk4/app"
import style from "./style.scss"
import DynamicIsland from "./widget/DynamicIsland"
import { toggleExpand } from "./widget/islandState"

app.start({
  css: style,
  requestHandler(argv, res) {
    if (argv[0] === "toggle-island") {
      toggleExpand()
      res("ok")
    } else {
      res("unknown request: " + argv[0])
    }
  },
  main() {
    app.get_monitors().map(DynamicIsland)
  },
})
