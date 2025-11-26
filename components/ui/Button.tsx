import React from 'react';
import { COMPONENT_STYLES, buildClassName } from '../../theme';

export type ButtonVariant = 'primary' | 'secondary' | 'ghost' | 'danger' | 'success';
export type ButtonSize = 'sm' | 'md' | 'lg';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  size?: ButtonSize;
  fullWidth?: boolean;
  children: React.ReactNode;
}

const VARIANT_STYLES: Record<ButtonVariant, string> = {
  primary: 'bg-blue-600 hover:bg-blue-500 text-white',
  secondary: 'bg-slate-900 hover:bg-slate-800 text-white border border-slate-800',
  ghost: 'bg-transparent hover:bg-slate-800 text-white',
  danger: 'bg-red-500 hover:bg-red-600 text-white',
  success: 'bg-green-500 hover:bg-green-600 text-white',
};

/**
 * Reusable Button Component
 * 
 * @example
 * <Button variant="primary" size="md">Click me</Button>
 * <Button variant="secondary" size="sm" fullWidth>Full Width</Button>
 */
export const Button: React.FC<ButtonProps> = ({
  variant = 'primary',
  size = 'md',
  fullWidth = false,
  children,
  className = '',
  disabled,
  ...props
}) => {
  const classes = buildClassName(
    COMPONENT_STYLES.button.base,
    COMPONENT_STYLES.button.size[size],
    VARIANT_STYLES[variant],
    fullWidth && 'w-full',
    className
  );

  return (
    <button
      className={classes}
      disabled={disabled}
      {...props}
    >
      {children}
    </button>
  );
};

