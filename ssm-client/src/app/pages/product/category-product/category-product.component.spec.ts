import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { CategoryProductComponent } from './category-product.component';
import { HttpClientTestingModule } from '@angular/common/http/testing';
import { RouterTestingModule } from '@angular/router/testing';
import { HeaderSetter } from 'src/app/core/data/header-setter';

describe('CategoryProductComponent', () => {
  let component: CategoryProductComponent;
  let fixture: ComponentFixture<CategoryProductComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ CategoryProductComponent ],
      imports:[HttpClientTestingModule,RouterTestingModule],
      providers:[HeaderSetter]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(CategoryProductComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('shold get product detail according to category selected by user',()=>{
    component.ngOnInit();
    expect(component.CategoryID).not.toBeNull();
    expect(component.products.length).toBeGreaterThan(0);
  });

  
});
