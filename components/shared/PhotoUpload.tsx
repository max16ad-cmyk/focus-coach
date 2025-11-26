import React, { useRef, useState } from 'react';
import { Camera, X, Upload } from 'lucide-react';
import { GLASS_EFFECTS, PREMIUM_COMPONENTS } from '../../theme-premium';

interface PhotoUploadProps {
  onImageSelect: (file: File) => void;
  currentImageUrl?: string;
  disabled?: boolean;
}

export const PhotoUpload: React.FC<PhotoUploadProps> = ({
  onImageSelect,
  currentImageUrl,
  disabled = false,
}) => {
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [preview, setPreview] = useState<string | null>(currentImageUrl || null);

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file && file.type.startsWith('image/')) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setPreview(reader.result as string);
      };
      reader.readAsDataURL(file);
      onImageSelect(file);
    }
  };

  const handleClick = () => {
    if (!disabled) {
      fileInputRef.current?.click();
    }
  };

  const handleRemove = (e: React.MouseEvent) => {
    e.stopPropagation();
    setPreview(null);
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

  return (
    <div className="space-y-4">
      <input
        ref={fileInputRef}
        type="file"
        accept="image/*"
        onChange={handleFileSelect}
        className="hidden"
        disabled={disabled}
      />

      {preview ? (
        <div className="relative">
          <div className={`${GLASS_EFFECTS.card.base} rounded-2xl overflow-hidden aspect-video`}>
            <img
              src={preview}
              alt="Vorschau"
              className="w-full h-full object-contain"
            />
          </div>
          {!disabled && (
            <button
              onClick={handleRemove}
              className="absolute top-4 right-4 bg-red-500/90 hover:bg-red-500 text-white rounded-full p-2 transition-all backdrop-blur-md border border-red-400/30"
            >
              <X size={18} />
            </button>
          )}
        </div>
      ) : (
        <button
          onClick={handleClick}
          disabled={disabled}
          className={`w-full aspect-video ${GLASS_EFFECTS.card.base} rounded-2xl flex flex-col items-center justify-center gap-4 hover:bg-white/[0.05] transition-all disabled:opacity-50 disabled:cursor-not-allowed group`}
        >
          <div className={`${GLASS_EFFECTS.card.base} rounded-full p-4 group-hover:scale-110 transition-transform`}>
            <Camera size={32} className="text-white/60" />
          </div>
          <span className="text-white/60 text-sm">Foto auswählen</span>
          <Upload size={18} className="text-white/40" />
        </button>
      )}
    </div>
  );
};
