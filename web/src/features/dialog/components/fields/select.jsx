import React from "react"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue
} from "@/components/ui/select"
import { Label } from "@/components/ui/label"
import { useController } from "react-hook-form"
import LibIcon from "../../../../components/LibIcon"
import { Checkbox } from "@/components/ui/checkbox"
import { Button } from "@/components/ui/button"
import {
  Popover,
  PopoverContent,
  PopoverTrigger
} from "@/components/ui/popover"

const SelectField = props => {
  const controller = useController({
    name: `test.${props.index}.value`,
    control: props.control,
    rules: { required: props.row.required }
  })

  const baseClasses = "w-full"
  const iconClasses = "text-muted-foreground"

  // Normalizar opciones para que siempre sean { value, label }
  const normalizedOptions = props.row.options.map(opt =>
    typeof opt === "string" ? { value: opt, label: opt } : opt
  )

  return (
    <div className="space-y-2">
      {props.row.label && (
        <Label htmlFor={controller.field.name}>
          {props.row.label}
          {props.row.required && <span className="text-destructive">*</span>}
        </Label>
      )}

      {props.row.type === "select" ? (
        <div className="relative">
          <Select
            value={controller.field.value || ""}
            onValueChange={controller.field.onChange}
            disabled={props.row.disabled}
            name={controller.field.name}
            onOpenChange={() => controller.field.onBlur()}
          >
            <SelectTrigger
              id={controller.field.name}
              className={`${baseClasses} ${props.row.icon ? "pl-8" : ""}`}
            >
              <SelectValue
                placeholder={props.row.placeholder || "Selecciona una opción"}
              />
            </SelectTrigger>
            <SelectContent>
              {props.row.clearable && controller.field.value && (
                <SelectItem value="">Limpiar</SelectItem>
              )}
              {normalizedOptions.map(option => (
                <SelectItem key={option.value} value={option.value}>
                  {option.label}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>

          {props.row.icon && (
            <span className="absolute left-2 top-1/2 -translate-y-1/2">
              <LibIcon
                icon={props.row.icon}
                className={iconClasses}
                fixedWidth
              />
            </span>
          )}
        </div>
      ) : (
        props.row.type === "multi-select" && (
          <div className="relative">
            <Popover>
              <PopoverTrigger asChild>
                <Button
                  variant="outline"
                  className={`${baseClasses} ${
                    props.row.icon ? "pl-8" : ""
                  } justify-between`}
                  disabled={props.row.disabled}
                >
                  <span>
                    {controller.field.value?.length > 0
                      ? `${controller.field.value.length} seleccionados`
                      : props.row.placeholder || "Selecciona opciones"}
                  </span>
                  <LibIcon icon="chevron-down" className={iconClasses} />
                </Button>
              </PopoverTrigger>
              <PopoverContent className="w-full p-0">
                <div className="max-h-60 overflow-y-auto p-2">
                  {normalizedOptions.map(option => (
                    <div
                      key={option.value}
                      className="flex items-center space-x-2 py-1"
                    >
                      <Checkbox
                        id={`${controller.field.name}-${option.value}`}
                        checked={controller.field.value?.includes(option.value)}
                        onCheckedChange={checked => {
                          const currentValue = controller.field.value || []
                          const newValue = checked
                            ? [...currentValue, option.value].slice(
                                0,
                                props.row.maxSelectedValues
                              )
                            : currentValue.filter(v => v !== option.value)
                          controller.field.onChange(newValue)
                        }}
                        disabled={
                          props.row.disabled ||
                          (!controller.field.value?.includes(option.value) &&
                            props.row.maxSelectedValues !== undefined &&
                            controller.field.value?.length >=
                              props.row.maxSelectedValues)
                        }
                      />
                      <label
                        htmlFor={`${controller.field.name}-${option.value}`}
                        className="text-sm"
                      >
                        {option.label}
                      </label>
                    </div>
                  ))}
                </div>
                {props.row.clearable && controller.field.value?.length > 0 && (
                  <Button
                    variant="ghost"
                    className="w-full"
                    onClick={() => controller.field.onChange([])}
                  >
                    Limpiar
                  </Button>
                )}
              </PopoverContent>
            </Popover>

            {props.row.icon && (
              <span className="absolute left-2 top-1/2 -translate-y-1/2">
                <LibIcon
                  icon={props.row.icon}
                  className={iconClasses}
                  fixedWidth
                />
              </span>
            )}
          </div>
        )
      )}

      {props.row.description && (
        <p className="text-sm text-muted-foreground">{props.row.description}</p>
      )}
    </div>
  )
}

export default SelectField
