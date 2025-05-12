import React, { useState } from "react"
import { useController } from "react-hook-form"
import ColorPicker, { useColorPicker } from "react-best-gradient-color-picker"
import LibIcon from "../../../../components/LibIcon"
import { Label } from "@/components/ui/label"
import {
  Popover,
  PopoverTrigger,
  PopoverContent
} from "@/components/ui/popover"
import { Button } from "@/components/ui/button"

const ColorField = ({ row, index, control }) => {
  const { field } = useController({
    name: `test.${index}.value`,
    control,
    defaultValue:
      row.default ||
      (row.format === "gradient"
        ? "linear-gradient(90deg, rgba(255,255,255,1) 0%, rgba(0,0,0,1) 100%)"
        : "#ffffff"),
    rules: { required: row.required }
  })

  const [color, setColor] = useState(
    field.value ||
      (row.format === "gradient"
        ? "linear-gradient(90deg, rgba(255,255,255,1) 0%, rgba(0,0,0,1) 100%)"
        : "#ffffff")
  )

  // Sincronizar el estado del color con el campo de react-hook-form
  const handleColorChange = newColor => {
    setColor(newColor)
    field.onChange(newColor)
  }

  // Usar useColorPicker para manejar el picker
  const { getGradientObject } = useColorPicker(color, handleColorChange)

  return (
    <div className="flex flex-col gap-1">
      {row.label && (
        <Label className="text-foreground">
          {row.label}
          {row.required && <span className="text-red-500"> *</span>}
        </Label>
      )}
      {row.description && (
        <p className="text-sm text-muted-foreground">{row.description}</p>
      )}
      <div className="relative">
        <Popover>
          <PopoverTrigger className="w-full">
            <Button
              type="button"
              variant="outline"
              className="w-full justify-start text-left font-normal h-9 border-border"
            >
              <div className="w-full flex items-center gap-2">
                {row.icon && (
                  <LibIcon
                    icon={row.icon}
                    fixedWidth
                    className="text-foreground"
                  />
                )}
                <div
                  className="h-4 w-4 rounded !bg-center !bg-cover transition-all border"
                  style={{ background: color }}
                />
                <div className="truncate flex-1 text-foreground">{color}</div>
              </div>
            </Button>
          </PopoverTrigger>
          <PopoverContent className="w-80 p-3 bg-background border-border">
            <ColorPicker
              value={color}
              onChange={handleColorChange}
              hideColorTypeBtns={row.format !== "gradient"}
              hideControls={true}
              style={{ width: "100%" }}
              className={"!bg-transparent"}
            />
          </PopoverContent>
        </Popover>
      </div>
    </div>
  )
}

export default ColorField
