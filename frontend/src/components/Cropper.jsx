import React, {useState, useRef} from "react";
import CropperLib from "react-easy-crop";
import getCroppedImg from "../utils/cropImage"; // utility to get Blob
import api from "../services/api";

export default function Cropper({onCropped}) {
  const [imageSrc, setImageSrc] = useState(null);
  const [crop, setCrop] = useState({x: 0, y: 0});
  const [zoom, setZoom] = useState(1);
  const inputRef = useRef();

  const onFileChange = async (e) => {
    const file = e.target.files[0];
    const src = URL.createObjectURL(file);
    setImageSrc(src);
  };

  const showCropped = async () => {
    const croppedBlob = await getCroppedImg(imageSrc, crop, zoom);
    const form = new FormData();
    form.append("user_email", ""); // prompt later
    form.append("file", croppedBlob, "pet.png");
    const result = await api.uploadImage(form);
    onCropped(result);
  };

  return (
    <div className="cropper-container">
      {!imageSrc ? (
        <input
          type="file"
          accept="image/*"
          onChange={onFileChange}
          ref={inputRef}
        />
      ) : (
        <>
          <CropperLib
            image={imageSrc}
            crop={crop}
            zoom={zoom}
            aspect={1}
            onCropChange={setCrop}
            onZoomChange={setZoom}
          />
          <button onClick={showCropped}>Crop & Upload</button>
        </>
      )}
    </div>
  );
}
