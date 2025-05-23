import { debugData } from "../../../utils/debugData"

export const debugRadial = () => {
  debugData([
    {
      action: "openRadialMenu",
      data: {
        items: [
          { icon: "palette", label: "Paint" },
          {
            iconWidth: 35,
            iconHeight: 35,
            icon:
              "https://icon-library.com/images/white-icon-png/white-icon-png-18.jpg",
            label: "External icon"
          },
          { icon: "warehouse", label: "Garage" },
          { icon: "palette", label: "Quite Long Text" },
          { icon: "palette", label: "Fahrzeuginteraktionen" },
          { icon: "palette", label: "Fahrzeuginteraktionen" },
          { icon: "palette", label: "Paint" }
        ]
      }
    }
  ])
}
