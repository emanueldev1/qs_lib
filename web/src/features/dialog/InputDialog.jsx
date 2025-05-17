import React, { useState, useCallback } from 'react';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { useLocales } from '../../providers/LocaleProvider';
import { fetchNui } from '../../utils/fetchNui';
import { useForm, useFieldArray } from 'react-hook-form';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { ScrollArea } from '@/components/ui/scroll-area';
import InputField from './components/fields/input';
import CheckboxField from './components/fields/checkbox';
import SelectField from './components/fields/select';
import NumberField from './components/fields/number';
import SliderField from './components/fields/slider';
import ColorField from './components/fields/color';
import DateField from './components/fields/date';
import TextareaField from './components/fields/textarea';
import TimeField from './components/fields/time';
import dayjs from 'dayjs';

const InputDialog = () => {
  const [dialogData, setDialogData] = useState({
    heading: '',
    rows: [{ type: 'input', label: '' }],
  });
  const [isVisible, setIsVisible] = useState(false);
  const { locale } = useLocales();

  // Initialize form and field array
  const { control, handleSubmit, register, reset, formState: { errors, isSubmitting }, trigger } = useForm({
    defaultValues: { test: [] },
    mode: 'onSubmit',
  });
  const { fields, append, remove } = useFieldArray({
    control,
    name: 'test',
  });

  // Handle NUI event to open dialog
  useNuiEvent('openDialog', (data) => {
    console.log('openDialog event:', JSON.stringify(data, null, 2));
    setDialogData(data);
    setIsVisible(true);
    remove(); // Clear previous fields

    data.rows.forEach((row, index) => {
      const rowData = typeof row === 'string' ? { type: 'input', label: row } : row;
      let value = null;

      if (rowData.type === 'checkbox') {
        value = rowData.checked || false;
      } else if (['date', 'date-range', 'time'].includes(rowData.type)) {
        value = rowData.default === true
          ? new Date().getTime()
          : Array.isArray(rowData.default)
            ? rowData.default.map((date) => new Date(date).getTime())
            : rowData.default
              ? new Date(rowData.default).getTime()
              : null;
      } else {
        value = rowData.default || null;
      }

      console.log(`Appending field ${index}:`, { value });
      append({ value });

      // Normalize select options
      if (rowData.type === 'select' || rowData.type === 'multi-select') {
        rowData.options = rowData.options?.map((option) => ({
          ...option,
          label: option.label || option.value,
        }));
      }
    });
  });

  // Handle NUI event to close dialog
  useNuiEvent('closeInputDialog', async () => {
    console.log('closeInputDialog event received');
    await handleClose(true);
  });

  // Handle dialog close
  const handleClose = useCallback(async (dontPost) => {
    console.log('handleClose called, dontPost:', dontPost);
    setIsVisible(false);
    await new Promise((resolve) => setTimeout(resolve, 200));
    reset({ test: [] });
    remove();
    if (!dontPost) {
      console.log('Sending handleInputData with no values');
      await fetchNui('handleInputData');
    }
  }, [reset, remove]);

  // Handle form submission
  const onSubmit = useCallback(async (data) => {
    console.log('onSubmit triggered, form data:', JSON.stringify(data, null, 2));
    console.log('Form errors:', JSON.stringify(errors, null, 2));

    try {
      setIsVisible(false);
      const values = [];

      for (let i = 0; i < dialogData.rows.length; i++) {
        const row = typeof dialogData.rows[i] === 'string'
          ? { type: 'input', label: dialogData.rows[i] }
          : dialogData.rows[i];
        const value = data.test[i]?.value ?? null;

        if ((row.type === 'date' || row.type === 'date-range') && row.returnString && value) {
          values.push(dayjs(value).format(row.format || 'DD/MM/YYYY'));
        } else {
          values.push(value);
        }
      }

      console.log('Submitting values:', values);
      await new Promise((resolve) => setTimeout(resolve, 200));
      reset({ test: [] });
      remove();
      await fetchNui('handleInputData', values);
      console.log('handleInputData sent successfully');
    } catch (error) {
      console.error('Error in onSubmit:', error);
    }
  }, [dialogData.rows, reset, remove, errors]);

  // Debug form submission
  const handleFormSubmit = async (e) => {
    console.log('Form submit event triggered, isSubmitting:', isSubmitting);
    console.log('Current form state:', JSON.stringify(control._formValues, null, 2));
    const isValid = await trigger(); // Manually trigger validation
    console.log('Form validation result:', isValid, 'Errors:', JSON.stringify(errors, null, 2));
    if (!isValid) {
      console.log('Validation failed, onSubmit will not be called');
    }
    handleSubmit(onSubmit)(e);
  };

  return (
    <Dialog
      open={isVisible}
      onOpenChange={(open) => {
        console.log('Dialog open changed:', open);
        if (!open) {
          handleClose();
        } else {
          setIsVisible(true);
        }
      }}
    >
      <DialogContent
        className="max-w-xs bg-background border-border text-foreground"
        onEscapeKeyDown={(e) => dialogData.options?.allowCancel === false && e.preventDefault()}
        onInteractOutside={(e) => e.preventDefault()}
      >
        <DialogHeader>
          <DialogTitle className="text-center w-full text-lg">
            {dialogData.heading}
          </DialogTitle>
        </DialogHeader>
        <form onSubmit={handleFormSubmit}>
          <ScrollArea className="max-h-[80vh] rounded-md">
            <div className="flex flex-col gap-4 p-4">
              {fields.map((field, index) => {
                const row = typeof dialogData.rows[index] === 'string'
                  ? { type: 'input', label: dialogData.rows[index] }
                  : dialogData.rows[index];
                return (
                  <React.Fragment key={field.id}>
                    {row.type === 'input' && (
                      <InputField
                        register={register(`test.${index}.value`, { required: row.required })}
                        row={row}
                        index={index}
                      />
                    )}
                    {row.type === 'checkbox' && (
                      <CheckboxField
                        register={register(`test.${index}.value`, { required: row.required })}
                        row={row}
                        index={index}
                      />
                    )}
                    {(row.type === 'select' || row.type === 'multi-select') && (
                      <SelectField
                        row={row}
                        index={index}
                        control={control}
                      />
                    )}
                    {row.type === 'number' && (
                      <NumberField
                        control={control}
                        row={row}
                        index={index}
                      />
                    )}
                    {row.type === 'slider' && (
                      <SliderField
                        control={control}
                        row={row}
                        index={index}
                      />
                    )}
                    {row.type === 'color' && (
                      <ColorField
                        control={control}
                        row={row}
                        index={index}
                      />
                    )}
                    {row.type === 'time' && (
                      <TimeField
                        control={control}
                        row={row}
                        index={index}
                      />
                    )}
                    {(row.type === 'date' || row.type === 'date-range') && (
                      <DateField
                        control={control}
                        row={row}
                        index={index}
                      />
                    )}
                    {row.type === 'textarea' && (
                      <TextareaField
                        register={register(`test.${index}.value`, { required: row.required })}
                        row={row}
                        index={index}
                      />
                    )}
                  </React.Fragment>
                );
              })}
              <div className="flex justify-end gap-2 mt-2 sticky bottom-0 bg-background p-4">
                <Button
                  variant="outline"
                  onClick={() => handleClose()}
                  className="uppercase"
                  disabled={dialogData.options?.allowCancel === false}
                >
                  {locale.interface.cancel}
                </Button>
                <Button type="submit" variant="secondary" className="uppercase">
                  {locale?.interface?.confirm}
                </Button>
              </div>
            </div>
          </ScrollArea>
        </form>
      </DialogContent>
    </Dialog>
  );
};

export default InputDialog;
