import { Component, OnInit } from '@angular/core';
import { CategoryService } from 'src/app/core/mock/category.service';

@Component({
  selector: 'app-footer',
  templateUrl: './footer.component.html',
  styleUrls: ['./footer.component.css']
})
export class FooterComponent implements OnInit {

  departments:any;

  constructor(private _categoryService:CategoryService ) { }

  ngOnInit() {
    this._categoryService.getDepartment()
    .subscribe(
      res=>{
        this.departments=res;
      }
    )
  }

}
