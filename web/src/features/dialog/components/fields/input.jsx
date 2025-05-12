import React, { useState } from 'react';
import LibIcon from '../../../../components/LibIcon';

const InputField = ({ register, row, index }) => {
  const [showPassword, setShowPassword] = useState(false);

  // Base input classes for Shadcn/UI-inspired styling
  const inputClasses = `
    w-full px-3 py-2 text-sm bg-gray-100 dark:bg-gray-800 border
    border-gray-300 dark:border-gray-600 rounded-md text-gray-900 dark:text-gray-100
    placeholder-gray-400 dark:placeholder-gray-500 focus:outline-none
    focus:ring-2 focus:ring-blue-500 focus:border-blue-500
    disabled:bg-gray-200 dark:disabled:bg-gray-700 disabled:cursor-not-allowed
    ${row.icon ? 'pl-10' : ''}
  `;

  // Icon container classes
  const iconClasses = `
    absolute left-3 top-1/2 -translate-y-1/2 text-gray-500 dark:text-gray-400
  `;

  // Password toggle icon classes
  const toggleIconClasses = `
    absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 dark:text-gray-400
    cursor-pointer hover:text-gray-700 dark:hover:text-gray-300
  `;

  return (
    <div className="flex flex-col gap-1">
      {/* Label */}
      {row.label && (
        <label
          htmlFor={`input-${index}`}
          className="text-sm font-medium text-gray-700 dark:text-gray-200"
        >
          {row.label}
          {row.required && <span className="text-red-500 ml-1">*</span>}
        </label>
      )}

      {/* Description */}
      {row.description && (
        <p className="text-xs text-gray-500 dark:text-gray-400">
          {row.description}
        </p>
      )}

      {/* Input Container */}
      <div className="relative">
        {/* Icon */}
        {row.icon && (
          <span className={iconClasses}>
            <LibIcon icon={row.icon} fixedWidth />
          </span>
        )}

        {/* Input */}
        {!row.password ? (
          <input
            {...register}
            id={`input-${index}`}
            type="text"
            defaultValue={row.default}
            placeholder={row.placeholder}
            minLength={row.min}
            maxLength={row.max}
            disabled={row.disabled}
            className={inputClasses}
          />
        ) : (
          <>
            <input
              {...register}
              id={`input-${index}`}
              type={showPassword ? 'text' : 'password'}
              defaultValue={row.default}
              placeholder={row.placeholder}
              minLength={row.min}
              maxLength={row.max}
              disabled={row.disabled}
              className={inputClasses}
            />
            <span
              className={toggleIconClasses}
              onClick={() => setShowPassword(!showPassword)}
            >
              <LibIcon
                icon={showPassword ? 'eye-slash' : 'eye'}
                fixedWidth
              />
            </span>
          </>
        )}
      </div>
    </div>
  );
};

export default InputField;
