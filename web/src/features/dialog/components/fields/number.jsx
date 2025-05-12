import React from "react"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { useController } from "react-hook-form"
import LibIcon from "../../../../components/LibIcon"

const NumberField = props => {
  const controller = useController({
    name: `test.${props.index}.value`,
    control: props.control,
    defaultValue: props.row.default,
    rules: {
      required: props.row.required,
      min: props.row.min,
      max: props.row.max
    }
  })

  const baseInputClasses =
    "w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
  const iconClasses = "text-muted-foreground"
  const buttonClasses =
    "absolute top-1/2 -translate-y-1/2 p-1 text-muted-foreground hover:text-foreground disabled:opacity-50 disabled:cursor-not-allowed"

  // Si no hay step definido, permitimos cualquier valor (incluidos decimales)
  const step = props.row.step ?? undefined
  const precision =
    step && step.toString().includes(".")
      ? step.toString().split(".")[1].length
      : 0

  const handleIncrement = () => {
    const currentValue = Number(controller.field.value) || 0
    // Si no hay step, incrementamos en 1 por defecto
    const stepValue = step ?? 1
    const newValue = step
      ? Number((currentValue + stepValue).toFixed(precision))
      : currentValue + 1
    if (props.row.max !== undefined && newValue > props.row.max) return
    controller.field.onChange(newValue)
  }

  const handleDecrement = () => {
    const currentValue = Number(controller.field.value) || 0
    // Si no hay step, decrementamos en 1 por defecto
    const stepValue = step ?? 1
    const newValue = step
      ? Number((currentValue - stepValue).toFixed(precision))
      : currentValue - 1
    if (props.row.min !== undefined && newValue < props.row.min) return
    controller.field.onChange(newValue)
  }

  const handleChange = e => {
    const value = e.target.value
    if (value === "") {
      controller.field.onChange(undefined) // Permitir campo vacío
    } else {
      const numValue = Number(value)
      if (!isNaN(numValue)) {
        // Solo ajustamos al step si está definido
        const adjustedValue = step
          ? Number((Math.round(numValue / step) * step).toFixed(precision))
          : numValue
        controller.field.onChange(adjustedValue)
      }
    }
  }

  return (
    <div className="space-y-2">
      {props.row.label && (
        <Label htmlFor={controller.field.name}>
          {props.row.label}
          {props.row.required && <span className="text-destructive">*</span>}
        </Label>
      )}

      <div className="relative">
        <Input
          type="number"
          id={controller.field.name}
          // Mostrar vacío si es undefined
          value={controller.field.value ?? ""}
          onChange={handleChange}
          onBlur={controller.field.onBlur}
          ref={controller.field.ref}
          min={props.row.min}
          max={props.row.max}
          // Usar 'any' para permitir decimales si no hay step
          step={step ?? "any"}
          disabled={props.row.disabled}
          className={`${baseInputClasses} ${
            props.row.icon ? "pl-10 pr-16" : "pr-16"
          }`}
          style={{
            MozAppearance: "textfield", // Elimina flechas en Firefox
            WebkitAppearance: "none" // Elimina flechas en Chrome/Safari
          }}
        />

        {props.row.icon && (
          <span className="absolute left-3 top-1/2 -translate-y-1/2">
            <LibIcon icon={props.row.icon} className={iconClasses} fixedWidth />
          </span>
        )}

        <div className="absolute right-1 top-1/2 -translate-y-1/2 flex items-center space-x-1">
          <button
            type="button"
            onClick={handleDecrement}
            disabled={
              props.row.disabled ||
              (props.row.min !== undefined &&
                (Number(controller.field.value) || 0) <= props.row.min)
            }
            className={`${buttonClasses} right-8 hover:cursor-pointer`}
          >
            <LibIcon icon="minus" className={iconClasses} fixedWidth />
          </button>
          <button
            type="button"
            onClick={handleIncrement}
            disabled={
              props.row.disabled ||
              (props.row.max !== undefined &&
                (Number(controller.field.value) || 0) >= props.row.max)
            }
            className={`${buttonClasses} right-2 hover:cursor-pointer`}
          >
            <LibIcon icon="plus" className={iconClasses} fixedWidth />
          </button>
        </div>
      </div>

      {props.row.description && (
        <p className="text-sm text-muted-foreground">{props.row.description}</p>
      )}
    </div>
  )
}

export default NumberField
