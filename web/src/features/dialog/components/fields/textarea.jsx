import React from "react"
import { Textarea } from "@/components/ui/textarea"
import { Label } from "@/components/ui/label"
import LibIcon from "../../../../components/LibIcon"

const TextareaField = props => {
  const baseTextareaClasses =
    "w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
  const iconClasses = "text-muted-foreground"

  return (
    <div className="space-y-2">
      {props.row.label && (
        <Label htmlFor={props.register.name}>
          {props.row.label}
          {props.row.required && <span className="text-destructive">*</span>}
        </Label>
      )}

      <div className="relative">
        <Textarea
          {...props.register}
          id={props.register.name}
          defaultValue={props.row.default}
          placeholder={props.row.placeholder}
          disabled={props.row.disabled}
          className={`${baseTextareaClasses} ${props.row.icon ? "pl-10" : ""}`}
          // Valor por defecto si no hay min
          rows={props.row.min || 3}
          maxRows={props.row.max}
          style={
            props.row.autosize ? { resize: "vertical" } : { resize: "none" }
          }
        />

        {props.row.icon && (
          <span className="absolute left-3 top-4">
            <LibIcon icon={props.row.icon} className={iconClasses} fixedWidth />
          </span>
        )}
      </div>

      {props.row.description && (
        <p className="text-sm text-muted-foreground">{props.row.description}</p>
      )}
    </div>
  )
}

export default TextareaField
