import React from 'react';
import { COMPONENT_STYLES, buildClassName } from '../../theme';

export type CardVariant = 'base' | 'elevated' | 'interactive';

interface CardProps {
  variant?: CardVariant;
  children: React.ReactNode;
  className?: string;
  onClick?: () => void;
}

/**
 * Reusable Card Component
 * 
 * @example
 * <Card variant="elevated">Content here</Card>
 * <Card variant="interactive" onClick={handleClick}>Clickable</Card>
 */
export const Card: React.FC<CardProps> = ({
  variant = 'base',
  children,
  className = '',
  onClick,
}) => {
  const classes = buildClassName(
    COMPONENT_STYLES.card[variant],
    className
  );

  return (
    <div className={classes} onClick={onClick}>
      {children}
    </div>
  );
};

/**
 * Card Header Component
 */
interface CardHeaderProps {
  title: string;
  subtitle?: string;
  icon?: React.ReactNode;
  action?: React.ReactNode;
}

export const CardHeader: React.FC<CardHeaderProps> = ({
  title,
  subtitle,
  icon,
  action,
}) => {
  return (
    <div className="flex items-start justify-between mb-4">
      <div className="flex items-center gap-3">
        {icon && <div className="text-2xl">{icon}</div>}
        <div>
          <h3 className="text-lg font-semibold text-white">{title}</h3>
          {subtitle && <p className="text-sm text-slate-400">{subtitle}</p>}
        </div>
      </div>
      {action && <div>{action}</div>}
    </div>
  );
};

/**
 * Card Content Component (for consistent padding)
 */
interface CardContentProps {
  children: React.ReactNode;
  className?: string;
}

export const CardContent: React.FC<CardContentProps> = ({
  children,
  className = '',
}) => {
  return <div className={buildClassName('p-6', className)}>{children}</div>;
};

