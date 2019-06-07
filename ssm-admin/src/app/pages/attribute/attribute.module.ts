import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AttributeListComponent } from './attribute-list/attribute-list.component';
import { FormsModule } from '@angular/forms';
import { ManageAttributeComponent } from './manage-attribute/manage-attribute.component';
import { RouterModule } from '@angular/router';

@NgModule({
  declarations: [AttributeListComponent, ManageAttributeComponent],
  imports: [
    CommonModule,
    FormsModule,
    RouterModule
  ]
})
export class AttributeModule { }
