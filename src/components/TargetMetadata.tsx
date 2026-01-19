type TargetMetadataProps = {
    origin?: string;
    context?: string;
    verified?: boolean;
};

const TargetMetadata = ({ origin = "IC/NGA", context = "Congressional", verified = true }: TargetMetadataProps) => {
    return (
        <div>
            <div className="text-[10px] text-text-muted mono mb-4 uppercase">Target Metadata</div>
            <div className="space-y-3">
                <div className="flex justify-between text-xs">
                    <span className="text-text-muted">Origin:</span>
                    <span className="text-white">{origin}</span>
                </div>
                <div className="flex justify-between text-xs">
                    <span className="text-text-muted">Context:</span>
                    <span className="text-white">{context}</span>
                </div>
                <div className="flex justify-between text-xs">
                    <span className="text-text-muted">Verified:</span>
                    <span className="text-primary">{verified ? "YES" : "NO"}</span>
                </div>
            </div>
        </div>
    );
};

export default TargetMetadata;
