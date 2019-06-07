import { Component, OnInit } from '@angular/core';
import { ProductService } from 'src/app/core/mock/product.service';
import { ActivatedRoute } from '@angular/router';

@Component({
  selector: 'app-product-image',
  templateUrl: './product-image.component.html',
  styleUrls: ['./product-image.component.css']
})
export class ProductImageComponent implements OnInit {

  images=new Array();
  uploadLabel=new Array(6);
  filesToUpload:Array<File>=[];
  variant_id;
  variant;
  list=new Array();

  constructor(private _productService:ProductService,
              private _route:ActivatedRoute) { }

  ngOnInit() {
    this._route.params.subscribe(
      params=>{
        this.variant_id=params.id;
        this._productService.getVariant(this.variant_id)
        .subscribe(
          res=>{
            this.variant=res[0];
            console.log(this.variant)
            this.list=JSON.parse(res[0].list_image);
            for(let i=0;i<6;i++){
              if(this.list.length>i){
                this.images[i]='../../../../assets/Images/list_image/'+this.list[i];
                this.uploadLabel[i]="Change Image";
              } else {
                this.uploadLabel[i]="Upload Image";
              }
            }
          }
        )
      }
    )
  }

  changeImage(files,index,event){
    var reader=new FileReader();
    if(files[0].size>2000000){
      window.alert("Please upload image less than < 2 MB");
      return ;
    }

    var mimeType=files[0].type;
    if(mimeType.match(/image\/*/)==null){
      window.alert("Please select images only");
      return;
    }

    this.filesToUpload=<Array<File>>event.target.files;
    reader.readAsDataURL(files[0]);
    reader.onload=(_event)=>{
      var img=new Image();
      //@ts-ignore
      img.src=reader.result;
      img.onload=()=>{
        //console.log(img.width,img.height)
        if(img.width<800 || img.height<800){
          window.alert("Please select image with minimum resolution 800*800");
          return;
        }
      };
      
      this.images[index]=reader.result;
    }
  }

  uploadImage(files,index){
    let check=0;
    if(this.uploadLabel[index]!=='Image Uploaded'){
      try{
        if(files[0].size>2000000){
          window.alert("Please upload image less than < 2 MB");
          check=1;
          return;
        } else {
  
            var mimeType=files[0].type;
            if(mimeType.match(/image\/*/)==null){
              window.alert("Please select images only");
              check=1;
              return;
            } else {
              var reader=new FileReader();
              reader.readAsDataURL(files[0]);
              reader.onload=(_event)=>{
                var img=new Image();
                //@ts-ignore
                img.src=reader.result;
                img.onload=()=>{
                  if(img.width<800 || img.height<800){
                    window.alert("Please select image with minimum resolution 800*800");
                    check=1;
                    return;
                  } else {
                    
                    if(check==0){
                      const formsData=new FormData();
                      const file:Array<File>=this.filesToUpload;
                      for(let i=0;i<file.length;i++){
                        formsData.append("uploads[]",file[i],files[i]['name']);
                      }
                      if(index<this.list.length){
                        let image=JSON.parse(this.variant.large_image)
                        this._productService.editUploadedImage(formsData,this.variant_id,image[index])
                        .subscribe(
                          res=>{
                            this.uploadLabel[index]="Image Uploaded";
                          },
                          err=>{
                            window.alert("Image is not uploaded. Please try again");
                          }
                        )

                      } else {
                        
                        // formsData.set('file',this.filesToUpload[0]);
                      
                        this._productService.uploadImage(formsData,this.variant_id)
                        .subscribe(
                          res=>{
                            this.uploadLabel[index]="Image Uploaded";
                          },
                          err=>{
                            console.log(err);
                          }
                        )
                      }
                    }
                  }
                };
              }
            }
        }
      } catch {
        window.alert("Please select the files")
      }
    } else {
      window.alert("This image uploaded already");
    }
  }
}
