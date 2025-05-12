import React from "react"
import { Checkbox } from "@/components/ui/checkbox"
import { Label } from "@/components/ui/label"

const CheckboxField = props => {
  const { row, register } = props

  return (
    <div className="flex items-center gap-2">
      <Checkbox
        // Necesario para asociar con el Label
        id={`checkbox-${props.index}`}
        {...register}
        required={row.required}
        defaultChecked={row.checked}
        disabled={row.disabled}
        className="border-border"
      />
      {row.label && (
        <Label htmlFor={`checkbox-${props.index}`} className="text-foreground">
          {row.label}
        </Label>
      )}
    </div>
  )
}

export default CheckboxField
