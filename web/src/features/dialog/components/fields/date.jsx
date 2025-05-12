import { useController } from "react-hook-form"
import { Calendar } from "@/components/ui/calendar" // Adjust path based on your setup
import {
  Popover,
  PopoverContent,
  PopoverTrigger
} from "@/components/ui/popover"
import { Button } from "@/components/ui/button"
import { cn } from "@/lib/utils" // Utility for conditional classNames
import { CalendarIcon } from "lucide-react" // Icon replacement for LibIcon
import { format } from "date-fns" // For date formatting
import React from "react"

const DateField = props => {
  const controller = useController({
    name: `test.${props.index}.value`,
    control: props.control,
    rules: {
      required: props.row.required,
      min: props.row.min,
      max: props.row.max
    }
  })

  const formatDate = date =>
    date ? format(date, props.row.format || "PPP") : "Pick a date"

  const formatRange = range => {
    if (!range || !range[0]) return "Pick a date range"
    const [from, to] = range
    return `${format(from, props.row.format || "PPP")}${
      to ? ` - ${format(to, props.row.format || "PPP")}` : ""
    }`
  }

  return (
    <>
      {props.row.type === "date" && (
        <div className="space-y-2">
          <label className="text-sm font-medium">
            {props.row.label}
            {props.row.required && <span className="text-red-500">*</span>}
          </label>
          {props.row.description && (
            <p className="text-sm text-muted-foreground">
              {props.row.description}
            </p>
          )}
          <Popover>
            <PopoverTrigger className="w-full">
              <Button
                type="button"
                variant="outline"
                className={cn(
                  "w-full justify-start text-left font-normal",
                  !controller.field.value && "text-muted-foreground",
                  props.row.disabled && "opacity-50 cursor-not-allowed"
                )}
                disabled={props.row.disabled}
              >
                <CalendarIcon className="mr-2 h-4 w-4" />
                {formatDate(
                  controller.field.value
                    ? new Date(controller.field.value)
                    : null
                )}
              </Button>
            </PopoverTrigger>
            <PopoverContent className="w-auto p-0">
              <Calendar
                mode="single"
                selected={
                  controller.field.value
                    ? new Date(controller.field.value)
                    : undefined
                }
                onSelect={date =>
                  controller.field.onChange(date ? date.getTime() : null)
                }
                disabled={props.row.disabled}
                fromDate={props.row.min ? new Date(props.row.min) : undefined}
                toDate={props.row.max ? new Date(props.row.max) : undefined}
                initialFocus
              />
              {props.row.clearable && controller.field.value && (
                <Button
                  variant="ghost"
                  className="w-full"
                  onClick={() => controller.field.onChange(null)}
                >
                  Clear
                </Button>
              )}
            </PopoverContent>
          </Popover>
        </div>
      )}
      {props.row.type === "date-range" && (
        <div className="space-y-2">
          <label className="text-sm font-medium">
            {props.row.label}
            {props.row.required && <span className="text-red-500">*</span>}
          </label>
          {props.row.description && (
            <p className="text-sm text-muted-foreground">
              {props.row.description}
            </p>
          )}
          <Popover>
            <PopoverTrigger className="w-full">
              <Button
                type="button"
                variant="outline"
                className={cn(
                  "w-full justify-start text-left font-normal",
                  !controller.field.value && "text-muted-foreground",
                  props.row.disabled && "opacity-50 cursor-not-allowed"
                )}
                disabled={props.row.disabled}
              >
                <CalendarIcon className="mr-2 h-4 w-4" />
                {formatRange(
                  controller.field.value
                    ? controller.field.value.map(date =>
                        date ? new Date(date) : null
                      )
                    : [null, null]
                )}
              </Button>
            </PopoverTrigger>
            <PopoverContent className="w-auto p-0">
              <Calendar
                mode="range"
                selected={
                  controller.field.value
                    ? {
                        from: controller.field.value[0]
                          ? new Date(controller.field.value[0])
                          : undefined,
                        to: controller.field.value[1]
                          ? new Date(controller.field.value[1])
                          : undefined
                      }
                    : undefined
                }
                onSelect={range =>
                  controller.field.onChange(
                    range
                      ? [
                          range.from?.getTime() ?? null,
                          range.to?.getTime() ?? null
                        ]
                      : [null, null]
                  )
                }
                disabled={props.row.disabled}
                fromDate={props.row.min ? new Date(props.row.min) : undefined}
                toDate={props.row.max ? new Date(props.row.max) : undefined}
                initialFocus
              />
              {props.row.clearable && controller.field.value && (
                <Button
                  variant="ghost"
                  className="w-full"
                  onClick={() => controller.field.onChange([null, null])}
                >
                  Clear
                </Button>
              )}
            </PopoverContent>
          </Popover>
        </div>
      )}
    </>
  )
}

export default DateField
