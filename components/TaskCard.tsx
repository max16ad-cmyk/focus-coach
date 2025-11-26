
import React, { useRef, useState } from 'react';
import { Task } from '../types';
import { Check, Sparkles, Camera, Loader2, XCircle } from 'lucide-react';
import { verifyTaskWithImage } from '../services/geminiService';

interface TaskCardProps {
  task: Task;
  onToggle: (id: string, verified?: boolean) => void;
  onDelete: (id: string) => void;
}

export const TaskCard: React.FC<TaskCardProps> = ({ task, onToggle, onDelete }) => {
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [isVerifying, setIsVerifying] = useState(false);
  const [feedback, setFeedback] = useState<string | null>(null);

  const handleFileChange = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    setIsVerifying(true);
    setFeedback(null);

    const reader = new FileReader();
    reader.onloadend = async () => {
        const base64String = reader.result as string;
        
        // Call AI Service
        const result = await verifyTaskWithImage(task.title, base64String);
        
        setIsVerifying(false);
        if (result.verified) {
            setFeedback("Verified!");
            setTimeout(() => {
                onToggle(task.id, true);
                setFeedback(null);
            }, 1000);
        } else {
            setFeedback(result.feedback); // "This looks like a cat..."
        }
    };
    reader.readAsDataURL(file);
  };

  const handleClick = () => {
      if (task.completed) {
          onToggle(task.id); // Uncheck
      } else if (task.verificationRequired) {
          fileInputRef.current?.click(); // Trigger camera/upload
      } else {
          onToggle(task.id); // Normal check
      }
  };

  return (
    <div 
      className={`group flex flex-col p-4 rounded-xl border transition-all duration-300 ${
        task.completed 
          ? 'bg-vault-800/50 border-vault-700 opacity-60' 
          : 'bg-vault-800 border-vault-700 hover:border-vault-accent'
      }`}
    >
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3 w-full">
            <button
            onClick={handleClick}
            disabled={isVerifying}
            className={`w-6 h-6 rounded-full border-2 flex items-center justify-center transition-colors flex-shrink-0 ${
                task.completed
                ? 'bg-vault-success border-vault-success'
                : task.verificationRequired
                    ? 'border-purple-500 hover:border-purple-400 text-purple-500' 
                    : 'border-vault-500 hover:border-vault-accent'
            }`}
            title={task.verificationRequired ? "Photo Proof Required" : "Mark Done"}
            >
            {isVerifying ? (
                <Loader2 size={12} className="animate-spin" />
            ) : task.completed ? (
                <Check size={14} className="text-white" />
            ) : task.verificationRequired ? (
                <Camera size={12} />
            ) : null}
            </button>

            <span className={`${task.completed ? 'line-through text-gray-500' : 'text-gray-200'} font-medium truncate`}>
            {task.title}
            </span>
            
            <div className="flex gap-1">
                {task.isAiGenerated && (
                    <Sparkles size={14} className="text-vault-gold opacity-70" title="AI Generated" />
                )}
                {task.verificationRequired && !task.completed && (
                    <span className="text-[10px] bg-purple-900/50 text-purple-300 px-1.5 py-0.5 rounded border border-purple-500/30 whitespace-nowrap">
                        Proof Req.
                    </span>
                )}
            </div>
        </div>
        
        <button 
            onClick={() => onDelete(task.id)}
            className="text-gray-600 hover:text-vault-danger opacity-0 group-hover:opacity-100 transition-opacity ml-2"
        >
            &times;
        </button>

        {/* Hidden File Input for Camera/Gallery */}
        <input 
            type="file" 
            ref={fileInputRef} 
            accept="image/*" 
            capture="environment" 
            className="hidden" 
            onChange={handleFileChange}
        />
      </div>

      {/* AI Feedback Message */}
      {feedback && (
          <div className={`mt-2 text-xs flex items-center gap-2 ${feedback === "Verified!" ? 'text-vault-success' : 'text-red-400'}`}>
              {feedback === "Verified!" ? <Check size={12} /> : <XCircle size={12} />}
              {feedback}
          </div>
      )}
    </div>
  );
};
