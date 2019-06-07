import { TestBed,async,inject } from '@angular/core/testing';
import { CategoryService } from './category.service';
import { HttpTestingController, HttpClientTestingModule } from '@angular/common/http/testing';
import { HeaderSetter } from '../data/header-setter';

describe('CategoryService', () => {
  beforeEach(() => TestBed.configureTestingModule({
    imports:[HttpClientTestingModule],
    providers:[HeaderSetter]
  }));

  it(`should create`, async(inject([HttpTestingController, CategoryService],
    (categoryService: CategoryService) => {
      expect(categoryService).toBeTruthy();
  })));
});
