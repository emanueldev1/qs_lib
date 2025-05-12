import React, { useState } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import {
  Popover,
  PopoverContent,
  PopoverTrigger
} from "@/components/ui/popover"
import { useController } from "react-hook-form"
import LibIcon from "../../../../components/LibIcon"

const TimeField = props => {
  const controller = useController({
    name: `test.${props.index}.value`,
    control: props.control,
    rules: { required: props.row.required }
  })

  const [isOpen, setIsOpen] = useState(false)

  // Convertir timestamp a formato legible (HH:MM AM/PM)
  const formatTimeValue = value => {
    if (!value) return ""
    const date = new Date(value)
    return date.toLocaleTimeString("en-US", {
      hour12: props.row.format === "12",
      hour: "2-digit",
      minute: "2-digit"
    })
  }

  // Actualizar valor desde el picker
  const handleTimeSelect = (hours, minutes, period) => {
    const date = new Date()
    let h = hours
    if (props.row.format === "12" && period === "pm" && hours !== 12) h += 12
    if (props.row.format === "12" && period === "am" && hours === 12) h = 0
    date.setHours(h, minutes, 0, 0)
    controller.field.onChange(date.getTime())
    setIsOpen(false)
  }

  // Extraer horas y minutos del valor actual
  const getCurrentTime = value => {
    if (!value) return [6, 0, "am"] // Valor por defecto
    const date = new Date(value)
    const hours = date.getHours()
    const minutes = date.getMinutes()
    const period = hours >= 12 ? "pm" : "am"
    const h12 = hours % 12 || 12
    return [h12, minutes, period]
  }

  const [currentHours, currentMinutes, currentPeriod] = getCurrentTime(
    controller.field.value
  )

  return (
    <div className="space-y-2">
      {props.row.label && (
        <Label htmlFor={controller.field.name}>
          {props.row.label}
          {props.row.required && <span className="text-destructive">*</span>}
        </Label>
      )}

      <div className="relative">
        <Popover open={isOpen} onOpenChange={setIsOpen}>
          <PopoverTrigger asChild>
            <Input
              id={controller.field.name}
              value={formatTimeValue(controller.field.value)}
              onChange={e => {
                const [h, m] = e.target.value.split(":")
                if (h && m) {
                  const date = new Date()
                  date.setHours(Number(h), Number(m), 0, 0)
                  controller.field.onChange(date.getTime())
                }
              }}
              onBlur={controller.field.onBlur}
              ref={controller.field.ref}
              disabled={props.row.disabled}
              className={`w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50 ${
                props.row.icon ? "pl-10" : ""
              }`}
              // Evita edición directa, fuerza el uso del picker
              readOnly
            />
          </PopoverTrigger>
          <PopoverContent className="w-64 p-2 bg-background border border-input rounded-md">
            <div className="grid grid-cols-3 gap-2">
              {Array.from({ length: 12 }, (_, i) => i + 1).map(hour => (
                <Button
                  key={`hour-${hour}`}
                  variant={currentHours === hour ? "default" : "outline"}
                  className="w-full"
                  onClick={() =>
                    handleTimeSelect(hour, currentMinutes, currentPeriod)
                  }
                  disabled={props.row.disabled}
                >
                  {hour}
                </Button>
              ))}
              {Array.from({ length: 12 }, (_, i) => i + 12).map(hour => (
                <Button
                  key={`hour-${hour}`}
                  variant={
                    currentHours === (hour % 12 || 12) ? "default" : "outline"
                  }
                  className="w-full"
                  onClick={() =>
                    handleTimeSelect(
                      hour % 12 || 12,
                      currentMinutes,
                      currentPeriod === "am" ? "pm" : "am"
                    )
                  }
                  disabled={props.row.disabled}
                >
                  {hour % 12 || 12}
                </Button>
              ))}
              {["00", "15", "30", "45"].map(minute => (
                <Button
                  key={`min-${minute}`}
                  variant={
                    currentMinutes === Number(minute) ? "default" : "outline"
                  }
                  className="w-full"
                  onClick={() =>
                    handleTimeSelect(
                      currentHours,
                      Number(minute),
                      currentPeriod
                    )
                  }
                  disabled={props.row.disabled}
                >
                  {minute}
                </Button>
              ))}
              {["am", "pm"].map(period => (
                <Button
                  key={`period-${period}`}
                  variant={currentPeriod === period ? "default" : "outline"}
                  className="w-full"
                  onClick={() =>
                    handleTimeSelect(currentHours, currentMinutes, period)
                  }
                  disabled={props.row.disabled || props.row.format !== "12"}
                >
                  {period}
                </Button>
              ))}
            </div>
          </PopoverContent>
        </Popover>

        {props.row.icon && (
          <span className="absolute left-3 top-1/2 -translate-y-1/2">
            <LibIcon
              icon={props.row.icon}
              className="text-muted-foreground"
              fixedWidth
            />
          </span>
        )}

        {props.row.clearable && controller.field.value && (
          <button
            type="button"
            onClick={() => controller.field.onChange(null)}
            className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
          >
            <LibIcon icon="x" className="text-muted-foreground" fixedWidth />
          </button>
        )}
      </div>

      {props.row.description && (
        <p className="text-sm text-muted-foreground">{props.row.description}</p>
      )}
    </div>
  )
}

export default TimeField
