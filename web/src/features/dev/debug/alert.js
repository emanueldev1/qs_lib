import { debugData } from "../../../utils/debugData"

export const debugAlert = () => {
  debugData([
    {
      action: "sendAlert",
      data: {
        header: "Hello there",
        content: "General kenobi  \n Markdown works",
        centered: true,
        size: "lg",
        overflow: true,
        cancel: true
        // labels: {
        //   confirm: 'Ok',
        //   cancel: 'Not ok',
        // },
      }
    }
  ])
}
