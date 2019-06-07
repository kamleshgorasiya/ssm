import { TestBed } from '@angular/core/testing';

import { AttributeValueService } from './attribute-value.service';

describe('AttributeValueService', () => {
  beforeEach(() => TestBed.configureTestingModule({}));

  it('should be created', () => {
    const service: AttributeValueService = TestBed.get(AttributeValueService);
    expect(service).toBeTruthy();
  });
});
