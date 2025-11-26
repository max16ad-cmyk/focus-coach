import React from 'react';
import { COLORS, COMPONENT_STYLES, buildClassName } from '../../theme';

export type ButtonVariant = 'primary' | 'secondary' | 'ghost' | 'danger' | 'success';
export type ButtonSize = 'sm' | 'md' | 'lg';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  size?: ButtonSize;
  fullWidth?: boolean;
  children: React.ReactNode;
}

const VARIANT_STYLES: Record<ButtonVariant, string> = {
  primary: `bg-${COLORS.primary.DEFAULT} hover:bg-${COLORS.primary.hover} text-white`,
  secondary: `bg-${COLORS.background.elevated} hover:bg-${COLORS.background.hover} text-white border border-${COLORS.border.DEFAULT}`,
  ghost: `bg-transparent hover:bg-${COLORS.background.hover} text-white`,
  danger: `bg-${COLORS.status.error.DEFAULT} hover:bg-${COLORS.status.error.dark} text-white`,
  success: `bg-${COLORS.status.success.DEFAULT} hover:bg-${COLORS.status.success.dark} text-white`,
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

