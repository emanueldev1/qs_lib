import { debugData } from "../../../utils/debugData"

export const debugCustomNotification = () => {
  debugData([
    {
      action: "notify",
      data: {
        title: "Success",
        description: "Notification description",
        type: "success",
        id: "pogchamp",
        duration: 20000,
        style: {
          ".description": {
            color: "red"
          }
        }
      }
    }
  ])
  debugData([
    {
      action: "notify",
      data: {
        title: "Error",
        description: "Notification description",
        type: "error"
      }
    }
  ])
  debugData([
    {
      action: "notify",
      data: {
        title: "Custom icon success",
        description: "Notification description",
        type: "success",
        icon: "microchip",
        showDuration: false
      }
    }
  ])
}
