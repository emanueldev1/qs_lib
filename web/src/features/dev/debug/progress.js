import { debugData } from "../../../utils/debugData"

export const debugProgressbar = () => {
  debugData([
    {
      action: "progress",
      data: {
        label: "Using Lockpick",
        duration: 8000
      }
    }
  ])
}

export const debugCircleProgressbar = () => {
  debugData([
    {
      action: "circleProgress",
      data: {
        duration: 8000,
        label: "Using Armour"
      }
    }
  ])
}
