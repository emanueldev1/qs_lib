import React from "react"
import { Slider } from "@/components/ui/slider"
import { Label } from "@/components/ui/label"
import { useController } from "react-hook-form"

const SliderField = props => {
  const controller = useController({
    name: `test.${props.index}.value`,
    control: props.control,
    defaultValue: props.row.default || props.row.min || 0
  })

  const handleSliderChange = value => {
    // shadcn/ui Slider devuelve un array, tomamos el primer valor
    controller.field.onChange(value[0])
  }

  return (
    <div className="space-y-2">
      {props.row.label && (
        <Label htmlFor={controller.field.name} className="text-sm font-medium">
          {props.row.label}
        </Label>
      )}

      <div className="space-y-4">
        <Slider
          id={controller.field.name}
          value={[controller.field.value]}
          onValueChange={handleSliderChange}
          onBlur={controller.field.onBlur}
          ref={controller.field.ref}
          min={props.row.min || 0}
          max={props.row.max || 100}
          step={props.row.step || 1}
          disabled={props.row.disabled}
          className="w-full"
        />

        <div className="flex justify-between text-sm text-muted-foreground">
          <span>{props.row.min || 0}</span>
          <span>{props.row.max || 100}</span>
        </div>
      </div>
    </div>
  )
}

export default SliderField
