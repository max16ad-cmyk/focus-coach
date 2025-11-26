import React, { useRef, useState } from 'react';
import { Camera, X, Upload } from 'lucide-react';

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
          <div className="aspect-video bg-slate-800 rounded-lg overflow-hidden">
            <img
              src={preview}
              alt="Vorschau"
              className="w-full h-full object-contain"
            />
          </div>
          {!disabled && (
            <button
              onClick={handleRemove}
              className="absolute top-2 right-2 bg-red-600 hover:bg-red-500 text-white rounded-full p-2 transition-colors"
            >
              <X size={16} />
            </button>
          )}
        </div>
      ) : (
        <button
          onClick={handleClick}
          disabled={disabled}
          className="w-full aspect-video bg-slate-900/50 border-2 border-dashed border-slate-700 rounded-lg flex flex-col items-center justify-center gap-3 hover:border-slate-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <Camera size={48} className="text-slate-500" />
          <span className="text-slate-400">Foto auswählen</span>
          <Upload size={20} className="text-slate-500" />
        </button>
      )}
    </div>
  );
};

